QBCore = exports[Config.Core]:GetCoreObject()

QBCore.Functions.CreateUseableItem("nitrous", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shitter = Player.PlayerData.items[item.slot].info.status
    if shitter == "Filled" then
        TriggerClientEvent('smallresource:client:LoadNitrous', source)
    end
end)

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

RegisterServerEvent('5life-nitrous:server:particlePurge', function(data)
    TriggerClientEvent('5life-nitrous:client:particlePurge', -1, source, data)
end)

RegisterServerEvent("5life-nitrous:client:setNitrousBottle", function(info)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName('nitrous')
    Player.PlayerData.items[item.slot].info.status = info
    Player.Functions.SetInventory(Player.PlayerData.items)
end)