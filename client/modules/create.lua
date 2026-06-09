local Client = IchoBilling.Client
local Utils = IchoBilling.Utils

local function openInvoiceDialog(invoiceType, target)
    if invoiceType == 'job' and not Client.getJobBillingProfile() then
        Client.notify(IchoBilling.T('notify.job_create_unavailable'), 'error')
        return
    end

    local rows = {}

    rows[#rows + 1] = {
        type = 'number',
        label = IchoBilling.T('create.amount'),
        required = true,
        min = Config.Common.MinAmount,
        max = Config.Common.MaxAmount,
        precision = 0,
        step = 1
    }

    if invoiceType == 'job' then
        local profile = Client.getJobBillingProfile()

        rows[#rows + 1] = {
            type = 'slider',
            label = IchoBilling.T('create.pool_percent'),
            description = IchoBilling.T('create.pool_percent_help'),
            required = true,
            default = profile and profile.poolPercent or Config.JobBilling.DefaultPoolPercent or 100,
            min = 0,
            max = 100,
            step = 1
        }
    end

    rows[#rows + 1] = {
        type = 'textarea',
        label = IchoBilling.T('create.description'),
        description = IchoBilling.T('create.description_help', { max = Config.Common.MaxDescriptionLength }),
        required = true,
        autosize = true,
        min = 2,
        max = 4,
        maxLength = Config.Common.MaxDescriptionLength
    }

    local input = lib.inputDialog(IchoBilling.T('create.title', {
        type = Utils.getInvoiceTypeLabel(invoiceType)
    }), rows, { size = 'md' })

    if not input then return end

    local amount = tonumber(input[1])
    local poolPercent = nil
    local descriptionIndex = 2

    if invoiceType == 'job' then
        poolPercent = tonumber(input[2])
        descriptionIndex = 3
    end

    local description = tostring(input[descriptionIndex] or '')

    TriggerServerEvent('icho_billing:server:createInvoice', invoiceType, target.serverId, amount, description, poolPercent)
end

local function openNearbyPlayers(invoiceType)
    local nearbyPlayers = Client.getNearbyPlayers()
    local options = {}

    if #nearbyPlayers == 0 then
        options[#options + 1] = {
            title = IchoBilling.T('create.nearby_empty'),
            description = IchoBilling.T('create.nearby_empty_help', {
                distance = ('%.1f'):format(Config.Common.MaxDistance)
            }),
            icon = 'circle-info',
            disabled = true
        }
    else
        for _, player in ipairs(nearbyPlayers) do
            local row = player
            options[#options + 1] = {
                title = ('ID %s - %s'):format(row.serverId, row.name),
                description = IchoBilling.T('create.nearby_distance', {
                    distance = ('%.1f'):format(row.distance)
                }),
                icon = 'user',
                onSelect = function()
                    openInvoiceDialog(invoiceType, row)
                end
            }
        end
    end

    lib.registerContext({
        id = ('icho_billing_nearby_%s'):format(invoiceType),
        title = IchoBilling.T('create.nearby_title', {
            type = Utils.getInvoiceTypeLabel(invoiceType)
        }),
        menu = 'icho_billing_main',
        position = Config.Menu.Position,
        options = options
    })

    lib.showContext(('icho_billing_nearby_%s'):format(invoiceType))
end

function Client.openCreateMenu()
    local options = {}

    if Config.PersonalBilling.Enabled then
        options[#options + 1] = {
            title = Config.PersonalBilling.Label or IchoBilling.T('menu.personal_billing'),
            description = IchoBilling.T('menu.personal_description'),
            icon = 'user-tag',
            onSelect = function()
                openNearbyPlayers('personal')
            end
        }
    end

    if Config.JobBilling.Enabled then
        local profile = Client.getJobBillingProfile()

        if profile then
            options[#options + 1] = {
                title = Config.JobBilling.Label or IchoBilling.T('menu.job_billing'),
                description = IchoBilling.T('menu.job_description', {
                    percent = profile.poolPercent,
                    job = profile.jobLabel or profile.jobName
                }),
                icon = 'briefcase',
                onSelect = function()
                    openNearbyPlayers('job')
                end
            }
        else
            options[#options + 1] = {
                title = Config.JobBilling.Label or IchoBilling.T('menu.job_billing'),
                description = IchoBilling.T('menu.job_unavailable'),
                icon = 'briefcase',
                disabled = true
            }
        end
    end

    options[#options + 1] = {
        title = IchoBilling.T('menu.unpaid'),
        description = IchoBilling.T('menu.unpaid_description'),
        icon = 'credit-card',
        onSelect = function()
            Client.openInvoiceList('received_unpaid')
        end
    }

    options[#options + 1] = {
        title = IchoBilling.T('menu.received'),
        description = IchoBilling.T('menu.received_description'),
        icon = 'inbox',
        onSelect = function()
            Client.openInvoiceList('received_all')
        end
    }

    options[#options + 1] = {
        title = IchoBilling.T('menu.sent'),
        description = IchoBilling.T('menu.sent_description'),
        icon = 'paper-plane',
        onSelect = function()
            Client.openInvoiceList('sent_all')
        end
    }

    lib.registerContext({
        id = 'icho_billing_main',
        title = Config.Menu.Title or IchoBilling.T('menu.title'),
        position = Config.Menu.Position,
        options = options
    })

    lib.showContext('icho_billing_main')
end
