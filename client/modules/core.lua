local Client = IchoBilling.Client
local Utils = IchoBilling.Utils

Client.QBCore = exports['qb-core']:GetCoreObject()

function Client.notify(description, notifyType)
    lib.notify({
        title = IchoBilling.T('notify_title'),
        description = description,
        type = notifyType or 'inform'
    })
end

function Client.getPlayerJob()
    local data = Client.QBCore.Functions.GetPlayerData() or {}
    return data.job or {}
end

function Client.getJobBillingProfile()
    if not Config.JobBilling.Enabled then
        return nil
    end

    if GetResourceState(Config.JobBilling.PoolResource) ~= 'started' then
        return nil
    end

    local job = Client.getPlayerJob()
    local profile = Config.JobBilling.Jobs and Config.JobBilling.Jobs[job.name]

    if not profile or profile.enabled == false then
        return nil
    end

    local minGrade = tonumber(profile.minGrade) or 0
    local gradeLevel = tonumber(job.grade and job.grade.level or 0) or 0

    if gradeLevel < minGrade then
        return nil
    end

    local requireOnDuty = profile.requireOnDuty
    if requireOnDuty == nil then
        requireOnDuty = Config.JobBilling.RequireOnDuty
    end

    if requireOnDuty and not job.onduty then
        return nil
    end

    local poolPercent = math.floor(Utils.clamp(profile.poolPercent or Config.JobBilling.DefaultPoolPercent or 100, 0, 100))

    return {
        jobName = job.name,
        jobLabel = profile.label or job.label or job.name,
        poolAccount = profile.poolAccount or job.name,
        poolPercent = poolPercent
    }
end

function Client.fetchInvoices(listType, cb)
    Client.QBCore.Functions.TriggerCallback('icho_billing:server:getInvoices', function(invoices)
        cb(invoices or {})
    end, listType)
end

function Client.getNearbyPlayers()
    local playerId = PlayerId()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local players = {}

    for _, activePlayer in ipairs(GetActivePlayers()) do
        if activePlayer ~= playerId then
            local targetPed = GetPlayerPed(activePlayer)

            if targetPed ~= 0 then
                local targetCoords = GetEntityCoords(targetPed)
                local distance = #(playerCoords - targetCoords)

                if distance <= Config.Common.MaxDistance then
                    players[#players + 1] = {
                        serverId = GetPlayerServerId(activePlayer),
                        name = GetPlayerName(activePlayer),
                        distance = distance
                    }
                end
            end
        end
    end

    table.sort(players, function(a, b)
        return a.distance < b.distance
    end)

    return players
end
