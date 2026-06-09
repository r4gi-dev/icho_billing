local Client = IchoBilling.Client
local Utils = IchoBilling.Utils

local function getListTitle(listType)
    return IchoBilling.T(('history.%s'):format(listType or 'received_unpaid'))
end

local function buildInvoiceMetadata(invoice, listType)
    local counterparty = listType == 'sent_all' and invoice.recipient_name or invoice.issuer_name
    local metadata = {
        { label = IchoBilling.T('detail.metadata_type'), value = Utils.getInvoiceTypeLabel(invoice.invoice_type) },
        { label = IchoBilling.T('detail.metadata_counterparty'), value = counterparty or '-' },
        { label = IchoBilling.T('detail.metadata_amount'), value = Utils.formatMoney(invoice.amount) },
        { label = IchoBilling.T('detail.metadata_status'), value = Utils.getStatusLabel(invoice.status) },
        { label = IchoBilling.T('detail.metadata_created'), value = invoice.created_at or '-' },
        { label = IchoBilling.T('detail.metadata_paid_at'), value = invoice.paid_at or '-' },
        { label = IchoBilling.T('detail.metadata_paid_by'), value = invoice.paid_by_account or '-' },
        { label = IchoBilling.T('detail.metadata_description'), value = invoice.description or '-' }
    }

    if invoice.invoice_type == 'job' then
        metadata[#metadata + 1] = { label = IchoBilling.T('detail.metadata_job'), value = invoice.issuer_job_label or invoice.issuer_job_name or '-' }
        metadata[#metadata + 1] = { label = IchoBilling.T('detail.metadata_pool_account'), value = invoice.job_pool_account or '-' }
        metadata[#metadata + 1] = { label = IchoBilling.T('detail.metadata_pool_percent'), value = invoice.job_pool_percent and ('%s%%'):format(invoice.job_pool_percent) or '-' }
        metadata[#metadata + 1] = { label = IchoBilling.T('detail.metadata_pool_amount'), value = invoice.job_pool_amount and Utils.formatMoney(invoice.job_pool_amount) or '-' }
        metadata[#metadata + 1] = { label = IchoBilling.T('detail.metadata_remainder'), value = invoice.job_remainder_amount and Utils.formatMoney(invoice.job_remainder_amount) or '-' }
    end

    return metadata
end

local function openInvoiceDetail(invoice, listType)
    local status = invoice.status
    local options = {
        {
            title = IchoBilling.T('detail.content'),
            description = invoice.description or '-',
            icon = 'file-lines',
            disabled = true
        },
        {
            title = IchoBilling.T('detail.amount'),
            description = Utils.formatMoney(invoice.amount),
            icon = 'money-bill',
            disabled = true
        },
        {
            title = IchoBilling.T('detail.invoice_type'),
            description = Utils.getInvoiceTypeLabel(invoice.invoice_type),
            icon = 'tag',
            disabled = true
        },
        {
            title = IchoBilling.T('detail.status'),
            description = Utils.getStatusLabel(status),
            icon = Utils.getStatusIcon(status),
            iconColor = Utils.getStatusIconColor(status),
            disabled = true
        }
    }

    if invoice.invoice_type == 'job' then
        options[#options + 1] = {
            title = IchoBilling.T('detail.job_info'),
            description = invoice.issuer_job_label or invoice.issuer_job_name or '-',
            icon = 'briefcase',
            disabled = true
        }
        options[#options + 1] = {
            title = IchoBilling.T('detail.job_pool_split'),
            description = ('%s%% / %s'):format(invoice.job_pool_percent or 0, Utils.formatMoney(invoice.job_pool_amount or 0)),
            icon = 'building-columns',
            disabled = true
        }
        options[#options + 1] = {
            title = IchoBilling.T('detail.remainder'),
            description = Utils.formatMoney(invoice.job_remainder_amount or 0),
            icon = 'wallet',
            disabled = true
        }
    end

    if listType ~= 'sent_all' and status == 'unpaid' then
        options[#options + 1] = {
            title = IchoBilling.T('detail.pay'),
            description = IchoBilling.T('detail.pay_description', {
                amount = Utils.formatMoney(invoice.amount)
            }),
            icon = 'credit-card',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = IchoBilling.T('detail.pay_confirm_title'),
                    content = IchoBilling.T('detail.pay_confirm_content', {
                        id = invoice.id,
                        amount = Utils.formatMoney(invoice.amount),
                        description = invoice.description or '-'
                    }),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = IchoBilling.T('detail.confirm_pay'),
                        cancel = IchoBilling.T('detail.back')
                    }
                })

                if alert == 'confirm' then
                    TriggerServerEvent('icho_billing:server:payInvoice', invoice.id)
                else
                    Client.openInvoiceList(listType)
                end
            end
        }
    end

    if listType == 'sent_all' and status == 'unpaid' then
        options[#options + 1] = {
            title = IchoBilling.T('detail.cancel_invoice'),
            description = IchoBilling.T('detail.cancel_description'),
            icon = 'ban',
            iconColor = '#ef4444',
            onSelect = function()
                local alert = lib.alertDialog({
                    header = IchoBilling.T('detail.cancel_confirm_title'),
                    content = IchoBilling.T('detail.cancel_confirm_content', { id = invoice.id }),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = IchoBilling.T('detail.confirm_cancel'),
                        cancel = IchoBilling.T('detail.back')
                    }
                })

                if alert == 'confirm' then
                    TriggerServerEvent('icho_billing:server:cancelInvoice', invoice.id)
                else
                    Client.openInvoiceList(listType)
                end
            end
        }
    end

    lib.registerContext({
        id = ('icho_billing_detail_%s'):format(invoice.id),
        title = IchoBilling.T('detail.title', { id = invoice.id }),
        menu = ('icho_billing_list_%s'):format(listType),
        position = Config.Menu.Position,
        options = options
    })

    lib.showContext(('icho_billing_detail_%s'):format(invoice.id))
end

function Client.openInvoiceList(listType)
    listType = listType or 'received_unpaid'

    Client.fetchInvoices(listType, function(invoices)
        local options = {}

        if #invoices == 0 then
            options[#options + 1] = {
                title = IchoBilling.T('history.empty'),
                icon = 'circle-info',
                disabled = true
            }
        else
            for _, invoice in ipairs(invoices) do
                local row = invoice
                local status = row.status or 'unpaid'
                local counterparty = listType == 'sent_all' and row.recipient_name or row.issuer_name

                options[#options + 1] = {
                    title = IchoBilling.T('history.row_title', {
                        id = row.id,
                        type = Utils.getInvoiceTypeLabel(row.invoice_type),
                        amount = Utils.formatMoney(row.amount),
                        status = Utils.getStatusLabel(status)
                    }),
                    description = IchoBilling.T('history.row_description', {
                        counterparty = counterparty or '-',
                        description = row.description or '-'
                    }),
                    icon = Utils.getStatusIcon(status) or 'file-invoice',
                    iconColor = Utils.getStatusIconColor(status),
                    metadata = buildInvoiceMetadata(row, listType),
                    onSelect = function()
                        openInvoiceDetail(row, listType)
                    end
                }
            end
        end

        lib.registerContext({
            id = ('icho_billing_list_%s'):format(listType),
            title = getListTitle(listType),
            menu = 'icho_billing_main',
            position = Config.Menu.Position,
            options = options
        })

        lib.showContext(('icho_billing_list_%s'):format(listType))
    end)
end
