local Server = IchoBilling.Server
local Utils = IchoBilling.Utils

Server.QBCore.Functions.CreateCallback('icho_billing:server:getInvoices', function(source, cb, listType)
    local Player = Server.QBCore.Functions.GetPlayer(source)
    if not Player then
        cb({})
        return
    end

    local rows = Server.getInvoicesForPlayer(Player.PlayerData.citizenid, listType)
    cb(rows or {})
end)

RegisterNetEvent('icho_billing:server:createInvoice', function(invoiceType, targetId, amount, description, poolPercent)
    local src = source
    local Player = Server.QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    invoiceType = tostring(invoiceType or 'personal'):lower()
    targetId = tonumber(targetId)
    amount = math.floor(tonumber(amount) or 0)
    description = Utils.trim(description)

    if invoiceType ~= 'personal' and invoiceType ~= 'job' then
        Server.notify(src, IchoBilling.T('notify.invalid_type'), 'error')
        return
    end

    if not targetId then
        Server.notify(src, IchoBilling.T('notify.invalid_target'), 'error')
        return
    end

    local Target = Server.QBCore.Functions.GetPlayer(targetId)
    if not Target then
        Server.notify(src, IchoBilling.T('notify.target_not_found'), 'error')
        return
    end

    if not Config.Common.AllowSelfBilling and Player.PlayerData.citizenid == Target.PlayerData.citizenid then
        Server.notify(src, IchoBilling.T('notify.self_billing'), 'error')
        return
    end

    if not Server.isTargetNearby(src, Target.PlayerData.source) then
        Server.notify(src, IchoBilling.T('notify.target_too_far', {
            distance = ('%.1f'):format(Config.Common.MaxDistance)
        }), 'error')
        return
    end

    if amount < Config.Common.MinAmount or amount > Config.Common.MaxAmount then
        Server.notify(src, IchoBilling.T('notify.invalid_amount', {
            min = Utils.formatMoney(Config.Common.MinAmount),
            max = Utils.formatMoney(Config.Common.MaxAmount)
        }), 'error')
        return
    end

    if description == '' then
        Server.notify(src, IchoBilling.T('notify.empty_description'), 'error')
        return
    end

    if Utils.textLength(description) > Config.Common.MaxDescriptionLength then
        Server.notify(src, IchoBilling.T('notify.description_too_long', {
            max = Config.Common.MaxDescriptionLength
        }), 'error')
        return
    end

    local job = Player.PlayerData.job or {}
    local jobPoolAccount, jobPoolPercent, jobPoolAmount, jobRemainderAmount = nil, nil, nil, nil

    if invoiceType == 'job' then
        local jobProfile = Server.getJobBillingProfile(Player)
        if not jobProfile then
            Server.notify(src, IchoBilling.T('notify.job_config_unavailable'), 'error')
            return
        end

        jobPoolAccount = Server.resolveJobPoolAccount(job.name, jobProfile)
        jobPoolPercent = Utils.clamp(poolPercent or jobProfile.poolPercent or Config.JobBilling.DefaultPoolPercent or 100, 0, 100)
        jobPoolAmount = math.floor(amount * jobPoolPercent / 100)
        jobRemainderAmount = math.max(amount - jobPoolAmount, 0)
    end

    local invoiceId = Server.insertInvoice({
        invoiceType = invoiceType,
        issuerCitizenId = Player.PlayerData.citizenid,
        issuerName = Server.getPlayerName(Player),
        issuerJobName = job.name,
        issuerJobLabel = job.label,
        recipientCitizenId = Target.PlayerData.citizenid,
        recipientName = Server.getPlayerName(Target),
        amount = amount,
        description = description,
        jobPoolAccount = jobPoolAccount,
        jobPoolPercent = jobPoolPercent,
        jobPoolAmount = jobPoolAmount,
        jobRemainderAmount = jobRemainderAmount
    })

    if not invoiceId then
        Server.notify(src, IchoBilling.T('notify.create_failed'), 'error')
        return
    end

    local invoiceLabel = Utils.getInvoiceTypeLabel(invoiceType)
    local issuerName = Server.getPlayerName(Player)

    Server.notify(src, IchoBilling.T('notify.invoice_created', {
        type = invoiceLabel,
        id = invoiceId
    }), 'success')

    Server.notifyCitizen(Target.PlayerData.citizenid, IchoBilling.T('notify.invoice_received', {
        issuer = issuerName,
        amount = Utils.formatMoney(amount)
    }), 'inform')
end)

RegisterNetEvent('icho_billing:server:payInvoice', function(invoiceId)
    Server.payInvoice(source, invoiceId)
end)

RegisterNetEvent('icho_billing:server:cancelInvoice', function(invoiceId)
    local src = source
    local Player = Server.QBCore.Functions.GetPlayer(src)
    if not Player then
        return
    end

    invoiceId = tonumber(invoiceId)
    if not invoiceId then
        return
    end

    local invoice = Server.getInvoiceById(invoiceId)
    if not invoice or invoice.issuer_citizenid ~= Player.PlayerData.citizenid then
        Server.notify(src, IchoBilling.T('notify.invoice_not_found'), 'error')
        return
    end

    if invoice.status ~= 'unpaid' then
        Server.notify(src, IchoBilling.T('notify.cancel_only_unpaid'), 'error')
        TriggerClientEvent('icho_billing:client:refreshList', src, 'sent_all')
        return
    end

    local changed = Server.cancelInvoice(invoice.id, Player.PlayerData.citizenid)

    if not changed or changed < 1 then
        Server.notify(src, IchoBilling.T('notify.cancel_failed'), 'error')
        return
    end

    Server.notify(src, IchoBilling.T('notify.invoice_cancelled', { id = invoice.id }), 'success')
    Server.notifyCitizen(invoice.recipient_citizenid, IchoBilling.T('notify.invoice_cancelled_to_recipient', {
        id = invoice.id
    }), 'inform')
    TriggerClientEvent('icho_billing:client:refreshList', src, 'sent_all')
end)
