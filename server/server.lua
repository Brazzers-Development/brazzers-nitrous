local QBCore = exports[Config.Core]:GetCoreObject()

RegisterNetEvent('nitrous:server:LoadNitrous', function(Plate)
    TriggerClientEvent('nitrous:client:LoadNitrous', -1, Plate)
end)

RegisterNetEvent('nitrous:server:SyncFlames', function(netId, coords, rate)
    TriggerClientEvent('nitrous:client:SyncFlames', -1, netId, source, coords, rate)
end)

RegisterNetEvent('nitrous:server:UnloadNitrous', function(Plate)
    TriggerClientEvent('nitrous:client:UnloadNitrous', -1, Plate)
end)

RegisterNetEvent('nitrous:server:UpdateNitroLevel', function(Plate, level)
    TriggerClientEvent('nitrous:client:UpdateNitroLevel', -1, Plate, level)
end)

RegisterNetEvent('nitrous:server:StopSync', function(plate)
    TriggerClientEvent('nitrous:client:StopSync', -1, plate)
end)

RegisterServerEvent('brazzers-nitrous:server:particlePurge', function(data)
    TriggerClientEvent('brazzers-nitrous:client:particlePurge', -1, source, data)
end)

RegisterServerEvent("brazzers-nitrous:client:setNitrousBottle", function(info)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(Config.Nitrous)
    if not item then return end

    Player.PlayerData.items[item.slot].info.status = info
    Player.Functions.SetInventory(Player.PlayerData.items)
end)

QBCore.Functions.CreateUseableItem(Config.Nitrous, function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local info = Player.PlayerData.items[item.slot].info.status
    if info ~= 'Filled' then return TriggerClientEvent('QBCore:Notify', src, Lang:t("error.empty_nitrous_bottle"), 'error') end

    TriggerClientEvent('smallresource:client:LoadNitrous', src)
end)