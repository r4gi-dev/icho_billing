local Server = IchoBilling.Server
local Utils = IchoBilling.Utils

Server.QBCore = exports['qb-core']:GetCoreObject()

function Server.notify(src, description, notifyType)
    TriggerClientEvent('icho_billing:client:notify', src, {
        description = description,
        type = notifyType or 'inform'
    })
end

function Server.notifyCitizen(citizenid, description, notifyType)
    local Player = Server.QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player then
        Server.notify(Player.PlayerData.source, description, notifyType)
    end
end

function Server.getPlayerName(Player)
    local charinfo = Player.PlayerData.charinfo or {}
    local fullName = Utils.trim(('%s %s'):format(charinfo.firstname or '', charinfo.lastname or ''))

    if fullName == '' then
        fullName = GetPlayerName(Player.PlayerData.source) or Player.PlayerData.citizenid
    end

    return fullName
end

function Server.resolveJobPoolAccount(jobName, profile)
    if profile and profile.poolAccount and profile.poolAccount ~= '' then
        return profile.poolAccount
    end

    return jobName
end

function Server.isTargetNearby(src, targetSrc)
    if not Config.Common.RequireNearby then
        return true
    end

    local srcPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(targetSrc)

    if srcPed == 0 or targetPed == 0 then
        return false
    end

    local srcCoords = GetEntityCoords(srcPed)
    local targetCoords = GetEntityCoords(targetPed)

    return #(srcCoords - targetCoords) <= (Config.Common.MaxDistance + 0.25)
end

function Server.getJobBillingProfile(Player)
    if not Config.JobBilling.Enabled then
        return nil
    end

    if GetResourceState(Config.JobBilling.PoolResource) ~= 'started' then
        return nil
    end

    local job = Player.PlayerData.job or {}
    return Utils.resolveJobBillingProfile(job)
end
