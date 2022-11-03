local QBCore = exports[Config.Core]:GetCoreObject()

local purgeMode = false
local nitroMode = true

local nosUpdated = false
local nitroSoundEffect = false

local nitrousActivated = false
local purgeActivated = false

local NOSPFX = {}
local VehicleNitrous = {}
local PurgeEffects = {}
local Fxs = {}

local flowRate = 5

p_flame_location = {
	"exhaust",
	"exhaust_2",
	"exhaust_3",
	"exhaust_4",
	"exhaust_5",
	"exhaust_6",
	"exhaust_7",
	"exhaust_8",
	"exhaust_9",
	"exhaust_10",
	"exhaust_11",
	"exhaust_12",
	"exhaust_13",
	"exhaust_14",
	"exhaust_15",
	"exhaust_16",
}

ParticleDict = "veh_xs_vehicle_mods"
ParticleFx = "veh_nitrous"

-- Functions

local function trim(value)
	if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

local function enablePurgeSpray(vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot)
	UseParticleFxAssetNextCall('core')
	return StartNetworkedParticleFxLoopedOnEntity('ent_sht_steam', vehicle, xOffset, yOffset, zOffset, xRot, yRot, zRot, Config.FlowRate[flowRate]['flow'], false, false, false)
end

local function enablePurgeMode(vehicle, plate, enabled)
	if enabled then
		local bone = GetEntityBoneIndexByName(vehicle, 'platelight')
		local pos = GetWorldPositionOfEntityBone(vehicle, bone)
		local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)
		local ptfxs = {}
  
	  	for i=0,3 do
			local leftPurge = enablePurgeSpray(vehicle, off.x - 0.69, off.y + 4.26, off.z - 0.40 , 35.0, -55.0, 0.0, 1.0)
			local rightPurge = enablePurgeSpray(vehicle, off.x + 0.69, off.y + 4.26, off.z - 0.40 , 35.0, 55.0, 0.0, 1.0)
			SetParticleFxLoopedColour(leftPurge, 1.0, 1.0, 1.0)
			SetParticleFxLoopedColour(rightPurge, 1.0, 1.0, 1.0)
			table.insert(ptfxs, leftPurge)
			table.insert(ptfxs, rightPurge)
	  	end
  
		PurgeEffects[plate] = ptfxs
	else
	  	if PurgeEffects[plate] and #PurgeEffects[plate] > 0 then
			for _, particleId in ipairs(PurgeEffects[plate]) do
		  		StopParticleFxLooped(particleId)
			end
	  	end
	  	PurgeEffects[plate] = nil
	end
end

local function hasNitrous()
    local PlayerData = QBCore.Functions.GetPlayerData()
    if PlayerData.items then
        for _, v in pairs(PlayerData.items) do
            if v.name == Config.Nitrous then
                return true
            end
        end
    end
end

-- Keybinds/ Commands

RegisterCommand("+increaseflow", function()
	local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
	local currentVehicle = GetVehiclePedIsIn(PlayerPedId())
	local plate = trim(GetVehicleNumberPlateText(currentVehicle))
    if not isInVehicle then return end
	if not VehicleNitrous[plate] then return end
    if not VehicleNitrous[plate].hasnitro then return end
    if flowRate > 9 then return end

    flowRate = flowRate + 1
	QBCore.Functions.Notify(Lang:t("primary.flowrate", { value = flowRate}), "primary", 5000)
    Wait(500)
end)
RegisterKeyMapping("+increaseflow", "Increase Flow Rate", "keyboard", "UP")

RegisterCommand("+decreaseflow", function()
	local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
	local currentVehicle = GetVehiclePedIsIn(PlayerPedId())
	local plate = trim(GetVehicleNumberPlateText(currentVehicle))
    if not isInVehicle then return end
    if not VehicleNitrous[plate] then return end
    if not VehicleNitrous[plate].hasnitro then return end
    if flowRate < 2 then return end

    flowRate = flowRate - 1
	QBCore.Functions.Notify(Lang:t("primary.flowrate", { value = flowRate}), "primary", 5000)
    Wait(500)
end)
RegisterKeyMapping("+decreaseflow", "Decrease Flow Rate", "keyboard", "DOWN")

RegisterCommand("+cyclenitro", function()
	local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
	local currentVehicle = GetVehiclePedIsIn(PlayerPedId())
	local plate = trim(GetVehicleNumberPlateText(currentVehicle))
    if not isInVehicle then return end
    if not VehicleNitrous[plate] then return end
    if not VehicleNitrous[plate].hasnitro then return end

    if not purgeMode and nitroMode then
        purgeMode = true
        nitroMode = false
		QBCore.Functions.Notify(Lang:t("primary.mode_purge"), "primary", 2500)
    elseif not nitroMode and purgeMode then
        nitroMode = true
        purgeMode = false
        QBCore.Functions.Notify(Lang:t("primary.mode_nitrous"), "primary", 2500)
    end
end)
RegisterKeyMapping("+cyclenitro", "Cycle Modes", "keyboard", "LSHIFT")

-- Net Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('nitrous:GetNosLoadedVehs', function(vehs)
        VehicleNitrous = vehs
    end)
end)

RegisterNetEvent('smallresource:client:LoadNitrous', function()
    local isInVehicle = IsPedInAnyVehicle(PlayerPedId())
    local currentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local plate = trim(GetVehicleNumberPlateText(currentVehicle))

    if not isInVehicle then return end
    if GetPedInVehicleSeat(currentVehicle, -1) ~= PlayerPedId() then return end
    if nitrousActivated then return QBCore.Functions.Notify(Lang:t("error.nitrous_already_active"), "error") end
    if Config.NoBikes and IsThisModelABike(GetEntityModel(currentVehicle)) then return QBCore.Functions.Notify(Lang:t("error.load_bike"), "error") end
    if Config.TurboNeeded and not IsToggleModOn(currentVehicle, 18) then return QBCore.Functions.Notify(Lang:t("error.no_turbo"), "error") end
    if Config.EngineOff and GetIsVehicleEngineRunning(currentVehicle) then return QBCore.Functions.Notify(Lang:t("error.engine_on"), "error") end

    QBCore.Functions.Progressbar("use_nos", Lang:t("progressbar.load_nitrous"), Config.ConnectNitrous, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        if Config.EngineOff and GetIsVehicleEngineRunning(currentVehicle) then return QBCore.Functions.Notify(Lang:t("error.engine_remain_off"), "error") end
        TriggerServerEvent('brazzers-nitrous:client:setNitrousBottle', 'Empty')
        TriggerServerEvent('nitrous:server:LoadNitrous', plate)
	end, function()
		QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
    end)
end)

RegisterNetEvent('nitrous:client:StopSync', function(plate)
    for _, v in pairs(NOSPFX[plate]) do
        StopParticleFxLooped(v.pfx, 1)
        NOSPFX[plate][_].pfx = nil
    end
end)

RegisterNetEvent('nitrous:client:UpdateNitroLevel', function(plate, level)
    VehicleNitrous[plate].level = level
end)

RegisterNetEvent('nitrous:client:LoadNitrous', function(plate)
    VehicleNitrous[plate] = {
        hasnitro = true,
        level = 100,
    }
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = trim(GetVehicleNumberPlateText(CurrentVehicle))
    if CPlate == plate then
        TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[plate].hasnitro,  VehicleNitrous[plate].level, false)
    end
end)

RegisterNetEvent('nitrous:client:UnloadNitrous', function(plate)
    VehicleNitrous[plate] = nil
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = trim(GetVehicleNumberPlateText(CurrentVehicle))
    if CPlate == plate then
        nitrousActivated = false
        TriggerEvent('hud:client:UpdateNitrous', false, nil, false)
    end
end)

RegisterNetEvent('nitrous:client:SyncFlames', function(netid, nosid, coords, rate)
    local veh = NetToVeh(netid)
	local meCoords = GetEntityCoords(PlayerPedId())
	local distance = #(coords - meCoords)
	if distance < 200 then
		if veh ~= 0 then
			local myid = GetPlayerServerId(PlayerId())
			if NOSPFX[trim(GetVehicleNumberPlateText(veh))] == nil then
				NOSPFX[trim(GetVehicleNumberPlateText(veh))] = {}
			end
			if myid ~= nosid then
				for _,bones in pairs(p_flame_location) do
					if NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones] == nil then
						NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones] = {}
					end
					if GetEntityBoneIndexByName(veh, bones) ~= -1 then
						if NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones].pfx == nil then
							RequestNamedPtfxAsset(ParticleDict)
							while not HasNamedPtfxAssetLoaded(ParticleDict) do
								Wait(0)
							end
							SetPtfxAssetNextCall(ParticleDict)
							UseParticleFxAssetNextCall(ParticleDict)
							NOSPFX[trim(GetVehicleNumberPlateText(veh))][bones].pfx = StartParticleFxLoopedOnEntityBone(ParticleFx, veh, 0.0, -0.05, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(veh, bones), rate, 0.0, 0.0, 0.0)
							SetVehicleBoostActive(veh, 1)
						end
					end
				end
			end
		end
	end
end)

RegisterNetEvent('brazzers-nitrous:client:particlePurge', function(player, type)
	local src = GetPlayerFromServerId(player)
	local ped = GetPlayerPed(src)
	local veh = GetVehiclePedIsIn(ped, false)
	local plate = trim(GetVehicleNumberPlateText(veh))
	if type then
		enablePurgeMode(veh, plate, true)
	elseif not type then
		enablePurgeMode(veh, plate, false)
	end
end)

RegisterNetEvent("brazzers-nitrous:client:refillNitrous", function()
	if not hasNitrous() then return QBCore.Functions.Notify(Lang:t("error.no_nitrous"), "error") end

	QBCore.Functions.Progressbar("filling_nitrous", Lang:t("progressbar.fill_nitrous"), 15000, false, false, {
		  disableMovement = true,
		  disableCarMovement = false,
		  disableMouse = false,
		  disableCombat = true,
	}, {}, {}, {}, function()
		TriggerServerEvent("brazzers-nitrous:client:setNitrousBottle", 'Filled')
	end, function()
		QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
	end)
end)

-- Threads

CreateThread(function()
    while true do
        local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
        local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
        if IsInVehicle then
            local plate = trim(GetVehicleNumberPlateText(CurrentVehicle))
            if VehicleNitrous[plate] then
                if VehicleNitrous[plate].hasnitro then
					if nitroMode then
						if IsControlJustPressed(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
							SetVehicleEnginePowerMultiplier(CurrentVehicle, Config.FlowRate[flowRate]['boost'])
							nitrousActivated = true

							CreateThread(function()
								while nitrousActivated do
									if VehicleNitrous[plate].level - Config.FlowRate[flowRate]['consumption'] > 0 then
										TriggerServerEvent('nitrous:server:UpdateNitroLevel', plate, (VehicleNitrous[plate].level - Config.FlowRate[flowRate]['consumption']))
										TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[plate].hasnitro,  VehicleNitrous[plate].level, true)
									else
										TriggerServerEvent('nitrous:server:UnloadNitrous', plate)
										nitrousActivated = false
										nitroSoundEffect = false
										purgeActivated = false
										SetVehicleBoostActive(CurrentVehicle, 0)
										SetVehicleEnginePowerMultiplier(CurrentVehicle, 1.0)
										StopScreenEffect("RaceTurbo")
										for index,_ in pairs(Fxs) do
											StopParticleFxLooped(Fxs[index], 1)
											TriggerServerEvent('nitrous:server:StopSync', trim(GetVehicleNumberPlateText(CurrentVehicle)))
											Fxs[index] = nil
										end
									end
									Wait(100)
								end
							end)
						end
					elseif purgeMode then
						if IsControlJustPressed(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
							SetVehicleBoostActive(CurrentVehicle, 1)
							purgeActivated = true
							TriggerServerEvent('brazzers-nitrous:server:particlePurge', true)

							CreateThread(function()
								while purgeActivated do
									if VehicleNitrous[plate].level - Config.FlowRate[flowRate]['consumption'] > 0 then
										TriggerServerEvent('nitrous:server:UpdateNitroLevel', plate, (VehicleNitrous[plate].level - Config.FlowRate[flowRate]['consumption']))
										TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[plate].hasnitro,  VehicleNitrous[plate].level, true)
									else
										TriggerServerEvent('nitrous:server:UnloadNitrous', plate)
										nitrousActivated = false
										purgeActivated = false
										SetVehicleBoostActive(CurrentVehicle, 0)
									end
									Wait(100)
								end
							end)
						end
                    end

					-- Releasing Controls

					if nitroMode then
						if IsControlJustReleased(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
							if nitrousActivated then
								local veh = GetVehiclePedIsIn(PlayerPedId())
								SetVehicleBoostActive(veh, 0)
								SetVehicleEnginePowerMultiplier(veh, 1.0)
								for index,_ in pairs(Fxs) do
									StopParticleFxLooped(Fxs[index], 1)
									TriggerServerEvent('nitrous:server:StopSync', trim(GetVehicleNumberPlateText(veh)))
									Fxs[index] = nil
								end
								StopScreenEffect("RaceTurbo")
								TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[plate].hasnitro,  VehicleNitrous[plate].level, false)
								nitroSoundEffect = false
								nitrousActivated = false
							end
						end
					elseif purgeMode then
						if IsControlJustReleased(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
							if purgeActivated then
								TriggerServerEvent('brazzers-nitrous:server:particlePurge', false)
								TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[plate].hasnitro,  VehicleNitrous[plate].level, false)
								purgeActivated = false
							end
						end
					end
                end
            else
                if not nosUpdated then
                    TriggerEvent('hud:client:UpdateNitrous', false, nil, false)
                    nosUpdated = true
                end
                StopScreenEffect("RaceTurbo")
            end
        else
            if nosUpdated then
                nosUpdated = false
            end
            StopScreenEffect("RaceTurbo")
            Wait(1500)
        end
        Wait(3)
    end
end)

CreateThread(function()
    while true do
        if nitrousActivated then
            local veh = GetVehiclePedIsIn(PlayerPedId())
			local pedCoords = GetEntityCoords(PlayerPedId())
            if veh ~= 0 then
                TriggerServerEvent('nitrous:server:SyncFlames', VehToNet(veh), pedCoords, Config.FlowRate[flowRate]['flow'])
				if not nitroSoundEffect then
					SetVehicleBoostActive(veh, 1)
					nitroSoundEffect = true
				end

                for _,bones in pairs(p_flame_location) do
                    if GetEntityBoneIndexByName(veh, bones) ~= -1 then
                        if Fxs[bones] == nil then
                            RequestNamedPtfxAsset(ParticleDict)
                            while not HasNamedPtfxAssetLoaded(ParticleDict) do
                                Wait(0)
                            end
                            SetPtfxAssetNextCall(ParticleDict)
                            UseParticleFxAssetNextCall(ParticleDict)
                            Fxs[bones] = StartParticleFxLoopedOnEntityBone(ParticleFx, veh, 0.0, -0.02, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(veh, bones), Config.FlowRate[flowRate]['flow'], 0.0, 0.0, 0.0)
                        end
                    end
                end
            end
        end
		if not nitrousActivated then
			Wait(100)
		end
        Wait(0)
    end
end)

if Config.EnablePed then
	exports[Config.Target]:SpawnPed({
		model = Config.Ped,
		coords = Config.PedLocation,
		minusOne = true,
		freeze = true,
		invincible = true,
		blockevents = true,
		scenario = 'WORLD_HUMAN_GUARD_STAND',
		target = {
			options = {
				{
					type = "client",
					event = "brazzers-nitrous:client:refillNitrous",
					icon = "fas fa-fill",
					label = "Refill Nitrous",
				}
			},
			distance = 2.5,
		},
	})
end