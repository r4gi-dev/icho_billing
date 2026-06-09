local Server = IchoBilling.Server
local Utils = IchoBilling.Utils

local function normalizeMoneyTable(money)
    if type(money) == 'string' then
        local ok, decoded = pcall(json.decode, money)
        if ok and type(decoded) == 'table' then
            money = decoded
        else
            money = {}
        end
    elseif type(money) ~= 'table' then
        money = {}
    end

    money.bank = math.floor(tonumber(money.bank) or 0)

    if money.cash ~= nil then
        money.cash = math.floor(tonumber(money.cash) or 0)
    end

    return money
end

local function adjustCitizenBank(citizenid, delta, reason)
    delta = math.floor(tonumber(delta) or 0)
    if delta == 0 then
        return true
    end

    local onlinePlayer = Server.QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if onlinePlayer then
        if delta > 0 then
            onlinePlayer.Functions.AddMoney('bank', delta, reason or 'icho_billing')
            return true
        end

        return onlinePlayer.Functions.RemoveMoney('bank', math.abs(delta), reason or 'icho_billing')
    end

    local row = MySQL.single.await('SELECT money FROM players WHERE citizenid = ? LIMIT 1', { citizenid })
    if not row or row.money == nil then
        return false
    end

    local money = normalizeMoneyTable(row.money)
    local nextBank = money.bank + delta

    if nextBank < 0 then
        return false
    end

    money.bank = nextBank

    local updated = MySQL.update.await('UPDATE players SET money = ? WHERE citizenid = ?', {
        json.encode(money),
        citizenid
    })

    return updated and updated > 0 or false
end

local function removePaymentFromPlayer(Player, amount)
    for _, account in ipairs(Config.Common.Accounts or {}) do
        local balance = Player.PlayerData.money and Player.PlayerData.money[account] or 0

        if balance >= amount and Player.Functions.RemoveMoney(account, amount, ('invoice-%s-payment'):format(account)) then
            return account
        end
    end

    return nil
end

local function refundPayment(Player, account, amount)
    if not account then
        return
    end

    Player.Functions.AddMoney(account, amount, 'icho_billing:refund')
end

local function creditJobPool(account, amount, reason)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        return true
    end

    if not account or account == '' then
        return false
    end

    if GetResourceState(Config.JobBilling.PoolResource) ~= 'started' then
        return false
    end

    local ok = pcall(function()
        exports[Config.JobBilling.PoolResource]:AddMoney(account, amount, reason or Config.JobBilling.PoolReason)
    end)

    return ok
end

local function creditPersonalInvoice(invoice, reason)
    return adjustCitizenBank(invoice.issuer_citizenid, invoice.amount, reason)
end

local function creditJobInvoice(invoice, payer, payerAccount, reason)
    local poolPercent = Utils.clamp(invoice.job_pool_percent or Config.JobBilling.DefaultPoolPercent or 100, 0, 100)
    local poolAmount = tonumber(invoice.job_pool_amount)
    local remainderAmount = tonumber(invoice.job_remainder_amount)
    local jobProfile = Config.JobBilling.Jobs and Config.JobBilling.Jobs[invoice.issuer_job_name]
    local poolAccount = invoice.job_pool_account or Server.resolveJobPoolAccount(invoice.issuer_job_name, jobProfile)

    if poolAmount == nil then
        poolAmount = math.floor(invoice.amount * poolPercent / 100)
    else
        poolAmount = math.floor(poolAmount)
    end

    if remainderAmount == nil then
        remainderAmount = math.max(invoice.amount - poolAmount, 0)
    else
        remainderAmount = math.floor(remainderAmount)
    end

    local remainderTarget = Config.JobBilling.RemainderTarget or 'issuer'

    if remainderTarget == 'issuer' and remainderAmount > 0 then
        if not adjustCitizenBank(invoice.issuer_citizenid, remainderAmount, reason) then
            Server.revertInvoiceToUnpaid(invoice.id)
            refundPayment(payer, payerAccount, invoice.amount)
            Server.notify(payer.PlayerData.source, IchoBilling.T('notify.issuer_split_failed'), 'error')
            return false
        end
    end

    if poolAmount > 0 and not creditJobPool(poolAccount, poolAmount, reason) then
        if remainderTarget == 'issuer' and remainderAmount > 0 then
            adjustCitizenBank(invoice.issuer_citizenid, -remainderAmount, reason)
        end

        Server.revertInvoiceToUnpaid(invoice.id)
        refundPayment(payer, payerAccount, invoice.amount)
        Server.notify(payer.PlayerData.source, IchoBilling.T('notify.job_pool_credit_failed'), 'error')
        return false
    end

    return true
end

function Server.payInvoice(src, invoiceId)
    local Player = Server.QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    invoiceId = tonumber(invoiceId)
    if not invoiceId then
        return
    end

    local invoice = Server.getInvoiceById(invoiceId)
    if not invoice or invoice.recipient_citizenid ~= Player.PlayerData.citizenid then
        Server.notify(src, IchoBilling.T('notify.invoice_not_found'), 'error')
        return
    end

    if invoice.status ~= 'unpaid' then
        Server.notify(src, IchoBilling.T('notify.invoice_already_processed'), 'error')
        TriggerClientEvent('icho_billing:client:refreshList', src, 'received_unpaid')
        return
    end

    local payerAccount = removePaymentFromPlayer(Player, invoice.amount)
    if not payerAccount then
        Server.notify(src, IchoBilling.T('notify.insufficient_funds'), 'error')
        return
    end

    local paid = Server.setInvoicePaid(invoice.id, Player.PlayerData.citizenid, payerAccount)
    if not paid or paid < 1 then
        refundPayment(Player, payerAccount, invoice.amount)
        Server.notify(src, IchoBilling.T('notify.payment_state_failed'), 'error')
        return
    end

    local reason = ('icho_billing:invoice:%s'):format(invoice.id)
    local credited = true

    if invoice.invoice_type == 'personal' then
        credited = creditPersonalInvoice(invoice, reason)

        if not credited then
            Server.revertInvoiceToUnpaid(invoice.id)
            refundPayment(Player, payerAccount, invoice.amount)
            Server.notify(src, IchoBilling.T('notify.issuer_credit_failed'), 'error')
            return
        end
    elseif invoice.invoice_type == 'job' then
        credited = creditJobInvoice(invoice, Player, payerAccount, reason)
        if not credited then
            return
        end
    end

    Server.notify(src, IchoBilling.T('notify.invoice_paid', { id = invoice.id }), 'success')
    Server.notifyCitizen(invoice.issuer_citizenid, IchoBilling.T('notify.invoice_paid_to_issuer', { id = invoice.id }), 'success')
    TriggerClientEvent('icho_billing:client:refreshList', src, 'received_unpaid')
end
