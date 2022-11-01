QBCore = exports[Config.Core]:GetCoreObject()

local purgeMode = false
local nitroMode = true

local nosupdated = false
local nitroSoundEffect = false

local NitrousActivated = false
local PurgeActivated = false

local NOSPFX = {}
local VehicleNitrous = {}
local Fxs = {}

local VehiclePurge = {}
local PurgeParticles = {}

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

local function enablePurgeMode(vehicle, enabled)
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
  
		VehiclePurge[vehicle] = true
		PurgeParticles[vehicle] = ptfxs
	else
	  	if PurgeParticles[vehicle] and #PurgeParticles[vehicle] > 0 then
			for _, particleId in ipairs(PurgeParticles[vehicle]) do
		  		StopParticleFxLooped(particleId)
			end
	  	end
	  	VehiclePurge[vehicle] = nil
	  	PurgeParticles[vehicle] = nil
	end
end

local function hasNitrous()
    PlayerData = QBCore.Functions.GetPlayerData()
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
    if not VehicleNitrous[plate].hasnitro then return end
    if flowRate > 9 then return end

    flowRate = flowRate + 1
    TriggerEvent("DoLongHudText", "Nitrous Flowrate: "..flowRate)
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
    TriggerEvent("DoLongHudText", "Nitrous Flowrate: "..flowRate)
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
        TriggerEvent("DoLongHudText", "Mode: Purge")
    elseif not nitroMode and purgeMode then
        nitroMode = true
        purgeMode = false
        TriggerEvent("DoLongHudText", "Mode: Nitrous")
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
    if GetPedInVehicleSeat(currentVehicle, -1) ~= ped then return end
    if NitrousActivated then return QBCore.Functions.Notify('You Already Have NOS Active', 'error') end
    if IsThisModelABike(GetEntityModel(currentVehicle)) then return QBCore.Functions.Notify('Cannot load nitrous in a bike', 'error') end
    if not IsToggleModOn(currentVehicle, 18) then return QBCore.Functions.Notify('You must have turbo installed to load this bottle of nitrous', 'error') end
    if GetIsVehicleEngineRunning(currentVehicle) then return QBCore.Functions.Notify('You can only load your bottle of nitrous with the engine off', 'error') end

    QBCore.Functions.Progressbar("use_nos", "Connecting NOS...", Config.ConnectNitrous, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        if GetIsVehicleEngineRunning(currentVehicle) then return QBCore.Functions.Notify("Engine must remain off to install", "error") end
        TriggerServerEvent('brazzers-nitrous:client:setNitrousBottle', 'Empty')
        TriggerServerEvent('nitrous:server:LoadNitrous', plate)
	end, function()
		QBCore.Functions.Notify("Canceled", "error")
    end)
end)

RegisterNetEvent('nitrous:client:StopSync', function(plate)
    for _, v in pairs(NOSPFX[plate]) do
        StopParticleFxLooped(v.pfx, 1)
        NOSPFX[plate][_].pfx = nil
    end
end)

RegisterNetEvent('nitrous:client:UpdateNitroLevel', function(Plate, level)
    VehicleNitrous[Plate].level = level
end)

RegisterNetEvent('nitrous:client:LoadNitrous', function(Plate)
    VehicleNitrous[Plate] = {
        hasnitro = true,
        level = 100,
    }
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = trim(GetVehicleNumberPlateText(CurrentVehicle))
    if CPlate == Plate then
        TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, false)
    end
end)

RegisterNetEvent('nitrous:client:UnloadNitrous', function(Plate)
    VehicleNitrous[Plate] = nil
    local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
    local CPlate = trim(GetVehicleNumberPlateText(CurrentVehicle))
    if CPlate == Plate then
        NitrousActivated = false
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

RegisterNetEvent('brazzers-nitrous:client:particlePurge', function (player, type)
	local src = GetPlayerFromServerId(player)
	local player = GetPlayerPed(src)
	local veh = GetVehiclePedIsIn(player, false)
	if type then
		enablePurgeMode(veh, true)
	elseif not type then
		enablePurgeMode(veh, false)
	end
end)

RegisterNetEvent("brazzers-nitrous:client:refillNitrous", function()
	if not hasNitrous() then return QBCore.Functions.Notify("You don\'t have any nitrous on you", "error") end

	QBCore.Functions.Progressbar("filling_nitrous", "Filling Nitrous Bottle", 15000, false, false, {
		  disableMovement = true,
		  disableCarMovement = false,
		  disableMouse = false,
		  disableCombat = true,
	}, {}, {}, {}, function()
		TriggerServerEvent("brazzers-nitrous:client:setNitrousBottle", 'Filled')
	end, function()
		QBCore.Functions.Notify("Canceled", "error")
	end)
end)

-- Threads

CreateThread(function()
    while true do
        local IsInVehicle = IsPedInAnyVehicle(PlayerPedId())
        local CurrentVehicle = GetVehiclePedIsIn(PlayerPedId())
        if IsInVehicle then
            local Plate = trim(GetVehicleNumberPlateText(CurrentVehicle))
            if VehicleNitrous[Plate] then
                if VehicleNitrous[Plate].hasnitro then
					if nitroMode then
						if IsControlJustPressed(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
							SetVehicleEnginePowerMultiplier(CurrentVehicle, Config.FlowRate[flowRate]['boost'])
							NitrousActivated = true

							CreateThread(function()
								while NitrousActivated do
									if VehicleNitrous[Plate].level - Config.FlowRate[flowRate]['consumption'] > 0 then
										TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - Config.FlowRate[flowRate]['consumption']))
										TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
									else
										TriggerServerEvent('nitrous:server:UnloadNitrous', Plate)
										NitrousActivated = false
										nitroSoundEffect = false
										PurgeActivated = false
										SetVehicleBoostActive(CurrentVehicle, 0)
										SetVehicleEnginePowerMultiplier(CurrentVehicle, LastEngineMultiplier)
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
							PurgeActivated = true
							TriggerServerEvent('brazzers-nitrous:server:particlePurge', true)

							CreateThread(function()
								while PurgeActivated do
									if VehicleNitrous[Plate].level - Config.FlowRate[flowRate]['consumption'] > 0 then
										TriggerServerEvent('nitrous:server:UpdateNitroLevel', Plate, (VehicleNitrous[Plate].level - Config.FlowRate[flowRate]['consumption']))
										TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, true)
									else
										TriggerServerEvent('nitrous:server:UnloadNitrous', Plate)
										NitrousActivated = false
										PurgeActivated = false
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
							if NitrousActivated then
								local veh = GetVehiclePedIsIn(PlayerPedId())
								SetVehicleBoostActive(veh, 0)
								SetVehicleEnginePowerMultiplier(veh, LastEngineMultiplier)
								for index,_ in pairs(Fxs) do
									StopParticleFxLooped(Fxs[index], 1)
									TriggerServerEvent('nitrous:server:StopSync', trim(GetVehicleNumberPlateText(veh)))
									Fxs[index] = nil
								end
								StopScreenEffect("RaceTurbo")
								TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, false)
								nitroSoundEffect = false
								NitrousActivated = false
							end
						end
					elseif purgeMode then
						if IsControlJustReleased(0, 36) and GetPedInVehicleSeat(CurrentVehicle, -1) == PlayerPedId() then
							if PurgeActivated then
								TriggerServerEvent('brazzers-nitrous:server:particlePurge', false)
								TriggerEvent('hud:client:UpdateNitrous', VehicleNitrous[Plate].hasnitro,  VehicleNitrous[Plate].level, false)
								PurgeActivated = false
							end
						end
					end
                end
            else
                if not nosupdated then
                    TriggerEvent('hud:client:UpdateNitrous', false, nil, false)
                    nosupdated = true
                end
                StopScreenEffect("RaceTurbo")
            end
        else
            if nosupdated then
                nosupdated = false
            end
            StopScreenEffect("RaceTurbo")
            Wait(1500)
        end
        Wait(3)
    end
end)

CreateThread(function()
    while true do
        if NitrousActivated then
            local veh = GetVehiclePedIsIn(PlayerPedId())
			local pedCoords = GetEntityCoords(PlayerPedId())
            if veh ~= 0 then
                TriggerServerEvent('nitrous:server:SyncFlames', VehToNet(veh), pedCoords, Config.FlowRate[flowRate]['flow'])
				if not nitroSoundEffect then
					SetVehicleBoostActive(veh, 1)
					nitroSoundEffect = true
				end
                --StartScreenEffect("RaceTurbo", 0.0, 0)

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
		if not NitrousActivated then
			Wait(100)
		end
        Wait(0)
    end
end)