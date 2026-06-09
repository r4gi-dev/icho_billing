IchoBilling.Utils = {}

function IchoBilling.Utils.trim(value)
    return tostring(value or ''):match('^%s*(.-)%s*$')
end

function IchoBilling.Utils.textLength(value)
    if utf8 and utf8.len then
        local ok, length = pcall(utf8.len, value)
        if ok and length then
            return length
        end
    end

    return #value
end

function IchoBilling.Utils.clamp(value, minValue, maxValue)
    value = tonumber(value) or 0
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function IchoBilling.Utils.formatMoney(amount)
    amount = math.floor(tonumber(amount) or 0)
    local formatted = tostring(amount)

    while true do
        local nextValue, count = formatted:gsub('^(-?%d+)(%d%d%d)', '%1,%2')
        formatted = nextValue
        if count == 0 then break end
    end

    return ('$%s'):format(formatted)
end

function IchoBilling.Utils.getInvoiceTypeLabel(invoiceType)
    return IchoBilling.T(('invoice_type.%s'):format(invoiceType or 'unknown'))
end

function IchoBilling.Utils.getStatusLabel(status)
    return IchoBilling.T(('status.%s'):format(status or 'unknown'))
end

function IchoBilling.Utils.getStatusIcon(status)
    return Config.UI.StatusIcon[status] or 'circle-info'
end

function IchoBilling.Utils.getStatusIconColor(status)
    return Config.UI.StatusIconColor[status]
end
