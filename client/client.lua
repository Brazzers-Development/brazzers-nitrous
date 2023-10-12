local vehicle
local activated, purging, screen = false, false, false
local noslvl, purgelvl, flowrate, nitrousMode = 0.0, 0.0, 0.0, false
local player, isInVehicle, isEnteringVehicle = PlayerId(), false, false
local purge = {}

-- Functions

function hasNitrous(vehicle)
    if not DecorExistOn(vehicle, "BRAZZERS_NITRO_STATUS") then
        return false
    end
    return DecorGetBool(vehicle, "BRAZZERS_NITRO_STATUS")
end exports('hasNitrous', hasNitrous)

function setNitrous(vehicle, status)
    DecorSetBool(vehicle, "BRAZZERS_NITRO_STATUS", status)
end exports('setNitrous', setNitrous)

function getValuesNOS(vehicle)
    return DecorGetFloat(vehicle, "BRAZZERS_NITRO_NOS"), DecorGetFloat(vehicle, "BRAZZERS_NITRO_PURGE"), DecorGetFloat(vehicle, "BRAZZERS_FLOWRATE")
end exports('getValuesNOS', getValuesNOS)

function getCurrentMode(vehicle)
    if not DecorExistOn(vehicle, "BRAZZERS_MODE") then
        return false
    end
    return DecorGetBool(vehicle, "BRAZZERS_MODE")
end

function installNitrous(vehicle)
    setNitrous(vehicle, true)
    DecorSetFloat(vehicle, "BRAZZERS_NITRO_NOS", 100.0)
    DecorSetFloat(vehicle, "BRAZZERS_NITRO_PURGE", 0.0)
    DecorSetFloat(vehicle, "BRAZZERS_FLOWRATE", 5.0)
    updateUI(true, 100.0)
end

function setNitrousLevel(vehicle, lvl)
    local formattedNumber = lvl + 0.0 -- Add 0.0 to convert it to a float
    setNitrous(vehicle, true)
    DecorSetFloat(vehicle, "BRAZZERS_NITRO_NOS", formattedNumber)
    DecorSetFloat(vehicle, "BRAZZERS_NITRO_PURGE", 0.0)
    DecorSetFloat(vehicle, "BRAZZERS_FLOWRATE", 5.0)
end exports('setNitrousLevel', setNitrousLevel)

-- Commands

RegisterCommand("+changeMode", function()
    vehicle = GetVehiclePedIsIn(cache.ped)
    if vehicle == 0 then return end
    local seatPed = GetPedInVehicleSeat(vehicle, -1)
    if seatPed ~= cache.ped then return end
    if not hasNitrous(vehicle) then return end

    nitrousMode = getCurrentMode(vehicle)
    if nitrousMode then
        DecorSetBool(vehicle, "BRAZZERS_MODE", false)
        notification(Config.Language.modepurge, "primary", 5000)
    elseif not nitrousMode then
        DecorSetBool(vehicle, "BRAZZERS_MODE", true)
        notification(Config.Language.modenitrous, "primary", 5000)
    end

    Wait(500)
end)
RegisterKeyMapping("+changeMode", "Vehicle: Change Nitrous Mode", "keyboard", "LSHIFT")

RegisterCommand("+activateNos", function()
    if not IsControlPressed(0, 71) then Wait(10) end

    vehicle = GetVehiclePedIsIn(cache.ped)
    if vehicle == 0 then return end
    local seatPed = GetPedInVehicleSeat(vehicle, -1)
    if seatPed ~= cache.ped then return end
    if not hasNitrous(vehicle) then return end

    nitrousMode = getCurrentMode(vehicle)
    if nitrousMode then
        lib.requestNamedPtfxAsset('veh_xs_vehicle_mods', 10)

        activated = true
        EnableVehicleExhaustPops(vehicle, false)
        SetVehicleBoostActive(vehicle, activated)
        TriggerServerEvent("brazzers-nitrous:flames", true)
    elseif not nitrousMode then
        purging = true
        TriggerServerEvent("brazzers-nitrous:setPurge", true)
    end
end, false)

RegisterCommand("-activateNos", function()
    vehicle = GetVehiclePedIsIn(cache.ped)
    if vehicle == 0 then return end
    local seatPed = GetPedInVehicleSeat(vehicle, -1)
    if seatPed ~= cache.ped then return end
    if not hasNitrous(vehicle) then return end

    nitrousMode = getCurrentMode(vehicle)
    if nitrousMode then
        activated = false
        TriggerServerEvent("brazzers-nitrous:flames", false)
        SetVehicleBoostActive(vehicle, activated)
        SetVehicleCheatPowerIncrease(vehicle, 1.0)

        screen = false
        StopGameplayCamShaking(true)
        SetTransitionTimecycleModifier("default", 0.35)
        Wait(1000)
        EnableVehicleExhaustPops(vehicle, true)
    elseif not nitrousMode then
        purging = false
        TriggerServerEvent("brazzers-nitrous:setPurge", false)
    end
end, false)
RegisterKeyMapping("+activateNos", "Vehicle: Activate Nitrous or Purge", "keyboard", "LCONTROL")

RegisterCommand("+increaseflow", function()
    vehicle = GetVehiclePedIsIn(cache.ped)
    if vehicle == 0 then return end
    local seatPed = GetPedInVehicleSeat(vehicle, -1)
    if seatPed ~= cache.ped then return end
    if not hasNitrous(vehicle) then return end

	noslvl, purgelvl, flowrate = getValuesNOS(vehicle)
	if flowrate >= 10.0 then return end

	flowrate += 1.0
	DecorSetFloat(vehicle, "BRAZZERS_FLOWRATE", flowrate)
    notification(Config.Language.flowrate..flowrate / 10, 'primary', 5000)
    Wait(500)
end)
RegisterKeyMapping("+increaseflow", "Vehicle: Increase Flow Rate", "keyboard", "UP")

RegisterCommand("+decreaseflow", function()
    vehicle = GetVehiclePedIsIn(cache.ped)
    if vehicle == 0 then return end
    local seatPed = GetPedInVehicleSeat(vehicle, -1)
    if seatPed ~= cache.ped then return end
    if not hasNitrous(vehicle) then return end
	if flowrate <= 1.0 then return end

	noslvl, purgelvl, flowrate = getValuesNOS(vehicle)
	flowrate -= 1.0
	DecorSetFloat(vehicle, "BRAZZERS_FLOWRATE", flowrate)
    notification(Config.Language.flowrate..flowrate / 10, 'primary', 5000)
    Wait(500)
end)
RegisterKeyMapping("+decreaseflow", "Vehicle: Decrease Flow Rate", "keyboard", "DOWN")

-- Threads

CreateThread(function()
    local wait = 1500
    while true do
        Wait(wait)
        if vehicle ~= 0 and hasNitrous(vehicle) then
            wait = 500
            noslvl, purgelvl, flowrate = getValuesNOS(vehicle)
            nitrousMode = getCurrentMode(vehicle)

            if noslvl < 1 then
                setNitrous(vehicle, false)

                activated = false
                TriggerServerEvent("brazzers-nitrous:flames", false)
                SetVehicleBoostActive(vehicle, activated)
                SetVehicleCheatPowerIncrease(vehicle, 1.0)
                screen = false
                StopGameplayCamShaking(true)
                SetTransitionTimecycleModifier("default", 0.35)
                EnableVehicleExhaustPops(vehicle, true)
                updateUI(false, nil)
            end

            if activated and noslvl > 0 then
                local lvl = noslvl - Config.FlowRate[flowrate].consumption
				if lvl < 0 then lvl = 0 end
                DecorSetFloat(vehicle, "BRAZZERS_NITRO_NOS", lvl)
                updateUI(true, lvl)

                if Config.IncreasePressure then
                    if purgelvl < 100 then
                        local lvl = purgelvl + Config.FlowRate[flowrate].consumption * Config.PressureMultiplier
                        DecorSetFloat(vehicle, "BRAZZERS_NITRO_PURGE", lvl)
                    end
                end
            end

            if purging and purgelvl > 0 then
                local lvl = purgelvl - Config.FlowRate[flowrate].consumption * Config.PurgeConsumptionMultiplier
				if lvl < 0 then lvl = 0 end
                DecorSetFloat(vehicle, "BRAZZERS_NITRO_PURGE", lvl)
            elseif purging and purgelvl <= 0 and Config.DecreaseNitrous then
                local lvl = noslvl - Config.FlowRate[flowrate].consumption
                DecorSetFloat(vehicle, "BRAZZERS_NITRO_NOS", lvl)
                updateUI(true, lvl)
            end
        else
            wait = 1500
        end
    end
end)

CreateThread(function()
    Wait(500)
    local model = GetEntityModel(vehicle)
    local maxSpeed = GetVehicleModelMaxSpeed(model)
    local wait = 500
    while true do
        Wait(wait)
        if noslvl > 0 and purgelvl < 100 then
            if activated then
                wait = 0

                local speed = GetEntitySpeed(vehicle)
                local mph = speed * 2.236936

                local thisModel = GetEntityModel(vehicle)
                if model ~= thisModel or maxSpeed == 0 then
                    model = thisModel
                    maxSpeed = GetVehicleModelMaxSpeed(model)
                end

                if mph < 5.0 then
                    SetControlNormal(0, 71, 0.5)
                else
                    SetVehicleEnginePowerMultiplier(vehicle, Config.FlowRate[flowrate].power * 1.5)
                end

                if screen and mph < Config.ScreenSpeed then
                    screen = false
                    StopGameplayCamShaking(true)
                    SetTransitionTimecycleModifier("default", 0.35)
                elseif not screen and mph > Config.ScreenSpeed and Config.ScreenShake then
                    screen = true
                    SetTimecycleModifier("rply_motionblur")
                    ShakeGameplayCam("SKY_DIVING_SHAKE", 0.25)
                end

                EnableVehicleExhaustPops(vehicle, false)
            else
                wait = 500
                SetVehicleEnginePowerMultiplier(vehicle, 1.0)
            end
        elseif activated then
            wait = 500
            activated = false
            TriggerServerEvent("brazzers-nitrous:flames", false)
            SetVehicleBoostActive(vehicle, activated)
            SetVehicleCheatPowerIncrease(vehicle, 1.0)
            screen = false
            StopGameplayCamShaking(true)
            SetTransitionTimecycleModifier("default", 0.35)
            EnableVehicleExhaustPops(vehicle, true)
        else
            wait = 500
            SetVehicleEnginePowerMultiplier(vehicle, 1.0)
        end
    end
end)

CreateThread(function()
	while true do
		Wait(500)
		if not isInVehicle and not IsPlayerDead(player) then
            local vehicle = GetVehiclePedIsTryingToEnter(cache.ped)
			if vehicle ~= 0 and hasNitrous(vehicle) and not isEnteringVehicle and GetPedInVehicleSeat(vehicle, -1) then
                -- trying to enter a vehicle!
				isEnteringVehicle = true
                vehicle = vehicle
                updateUI(true, noslvl)
			elseif vehicle == 0 and hasNitrous(vehicle) and not IsPedInAnyVehicle(cache.ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(cache.ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				vehicle = GetVehiclePedIsUsing(cache.ped)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(cache.ped, false) or IsPlayerDead(player) then
				-- left vehicle
				isInVehicle = false
                updateUI(false, nil)

                if activated then
                    activated = false
                    TriggerServerEvent("brazzers-nitrous:flames", false, VehToNet(vehicle))
                    SetVehicleBoostActive(vehicle, activated)
                    SetVehicleCheatPowerIncrease(vehicle, 1.0)
                end
                if screen then
                    screen = false
                    StopGameplayCamShaking(true)
                    SetTransitionTimecycleModifier("default", 0.35)
                    Wait(1000)
                    EnableVehicleExhaustPops(vehicle, true)
                end
                if purging then
                    purging = false
                    TriggerServerEvent("brazzers-nitrous:setPurge", false, VehToNet(vehicle))
                end
			end
		end
		Wait(50)
	end
end)

-- Global

AddStateBagChangeHandler("brazzers_flames", nil, function(bagName, _, value, _, _)
    if value == nil then return end
    Wait(50)

    local netId = tonumber(bagName:gsub("entity:", ""), 10)
    local entity = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId)
    if not entity then return end

	lib.requestNamedPtfxAsset('veh_xs_vehicle_mods', 10)
    SetVehicleNitroEnabled(entity, value, 2.5, 1.1, 4.0, false)
end)

AddStateBagChangeHandler("brazzers_purge", nil, function(bagName, _, value, _, _)
    if value == nil then return end
    Wait(50)

    local netId = tonumber(bagName:gsub("entity:", ""), 10)
    local entity = NetworkDoesNetworkIdExist(netId) and NetworkGetEntityFromNetworkId(netId)
    if not entity then return end

	local _, _, flowrate = getValuesNOS(entity)

    if value then
        local bone = GetEntityBoneIndexByName(entity, "bonnet")
        local pos = GetWorldPositionOfEntityBone(entity, bone)
        local off = GetOffsetFromEntityGivenWorldCoords(entity, pos.x, pos.y, pos.z)
        if bone ~= -1 then
            UseParticleFxAssetNextCall("core")
            local leftPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x - 0.5, off.y + 0.05, off.z, 40.0, -20.0, 0.0, Config.FlowRate[flowrate].flow, false, false, false)
            UseParticleFxAssetNextCall("core")
            local rightPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x + 0.5, off.y + 0.05, off.z, 40.0, 20.0, 0.0, Config.FlowRate[flowrate].flow, false, false, false)
            purge[entity] = {left = leftPurge, right = rightPurge}
            return
        end
        local bone = GetEntityBoneIndexByName(entity, "engine")
        local pos = GetWorldPositionOfEntityBone(entity, bone)
        local off = GetOffsetFromEntityGivenWorldCoords(entity, pos.x, pos.y, pos.z)
        UseParticleFxAssetNextCall("core")
        local leftPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x - 0.5, off.y - 0.2, off.z + 0.2, 40.0, -20.0, 0.0, Config.FlowRate[flowrate].flow, false, false, false)
        UseParticleFxAssetNextCall("core")
        local rightPurge = StartParticleFxLoopedOnEntity("ent_sht_steam", entity, off.x + 0.5, off.y - 0.2, off.z + 0.2, 40.0, 20.0, 0.0, Config.FlowRate[flowrate].flow, false, false, false)
        purge[entity] = {left = leftPurge, right = rightPurge}
    else
        StopParticleFxLooped(purge[entity].left)
        StopParticleFxLooped(purge[entity].right)
        purge[entity] = nil
    end
end)

-- Decor

DecorRegister("BRAZZERS_NITRO_STATUS", 2)
DecorRegister("BRAZZERS_MODE", 2)
DecorRegister("BRAZZERS_NITRO_NOS", 1)
DecorRegister("BRAZZERS_NITRO_PURGE", 1)
DecorRegister("BRAZZERS_FLOWRATE", 1)