local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

function notification(message, type, time)
    QBCore.Functions.Notify(message, type, time)
end

function updateUI(enabled, value)
	TriggerEvent('hud:client:UpdateNitrous', enabled, value, false)
end

-- Events

RegisterNetEvent('brazzers-nitrous:client:refillTheFuckingBottle', function()
	QBCore.Functions.Progressbar("filling_nitrous", Config.Language.progressbarfill, 15000, false, false, {
		disableMovement = true,
		disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
	}, {}, {}, {}, function()
	    TriggerServerEvent("brazzers-nitrous:client:setNitrousBottle", 'Filled', false)
	end, function()
        notification(Config.Language.canceled, 'error')
	end)
end)

-- Threads

CreateThread(function()
    exports.ox_inventory:displayMetadata('nitrous', 'Tank')
end)

-- Items

exports('nitrous', function(data, slot)
	if slot.metadata.nitrous == 'Empty' then return end
	local vehicle = GetVehiclePedIsIn(cache.ped)
	if vehicle == 0 then return end

	if GetPedInVehicleSeat(vehicle, -1) ~= cache.ped then return end
	if hasNitrous(vehicle) then return end

    if GetVehicleClass(vehicle) == 18 then return end
	if Config.NoBikes and GetVehicleClass(vehicle) == 8 then return notification(Config.Language.nobikes, 'error') end
    if Config.TurboNeeded and not IsToggleModOn(vehicle, 18) then return notification(Config.Language.turboneeded, 'error') end
    if Config.EngineOff and GetIsVehicleEngineRunning(vehicle) then return notification(Config.Language.engineoff, 'error') end

	QBCore.Functions.Progressbar("use_nos", Config.Language.progressbarload, Config.ConnectNitrous, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        if Config.EngineOff and GetIsVehicleEngineRunning(vehicle) then return notification(Config.Language.engineoff, 'error') end
        TriggerServerEvent('brazzers-nitrous:client:setNitrousBottle', 'Empty', slot)
        installNitrous(vehicle)
	end, function()
        notification(Config.Language.canceled, 'error')
    end)
end)