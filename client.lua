RegisterNetEvent('icho_billing:client:openInvoiceList', function(listType)
    IchoBilling.Client.openInvoiceList(listType)
end)

RegisterNetEvent('icho_billing:client:notify', function(data)
    if type(data) ~= 'table' then return end
    IchoBilling.Client.notify(data.description or '', data.type or 'inform')
end)

RegisterNetEvent('icho_billing:client:refreshList', function(listType)
    IchoBilling.Client.openInvoiceList(listType or 'received_unpaid')
end)

RegisterCommand(Config.Command, function()
    IchoBilling.Client.openCreateMenu()
end, false)

RegisterKeyMapping(Config.Command, Config.KeybindDescription, 'keyboard', Config.DefaultKey)
