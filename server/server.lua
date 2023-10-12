RegisterNetEvent("brazzers-nitrous:setPurge", function(status, vehid)
    if vehid then
        local veh = NetworkGetEntityFromNetworkId(vehid)
        local state = Entity(veh).state
        state.brazzers_purge = status
        return
    end
    local ped = GetPlayerPed(source)
    local veh = GetVehiclePedIsIn(ped)
    if veh == 0 then return end
    local state = Entity(veh).state
    state.brazzers_purge = status
end)

RegisterNetEvent("brazzers-nitrous:flames", function(status, vehid)
    if vehid then
        local veh = NetworkGetEntityFromNetworkId(vehid)
        local state = Entity(veh).state
        state.brazzers_flames = status
        return
    end
    local ped = GetPlayerPed(source)
    local veh = GetVehiclePedIsIn(ped)
    if veh == 0 then return end
    local state = Entity(veh).state
    state.brazzers_flames = status
end)