ESX              = nil
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

function ManageFuel(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		local rnd = math.random(200, 800) / 10
		print("setting lvl to " .. rnd)
		SetFuel(vehicle, 100)
	end

	if IsVehicleEngineOn(vehicle) then
		local old = GetVehicleFuelLevel(vehicle)
		local reduction = Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10
		local new = old - reduction
		SetFuel(vehicle, new)
	end
end

Citizen.CreateThread(function()
	DecorRegister(Config.FuelDecor, 1)

	while true do
		Citizen.Wait(1000)
		local playerPed = PlayerPedId(-1)

		if IsPedInAnyVehicle(playerPed) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			if GetPedInVehicleSeat(vehicle, -1) == playerPed then
				ManageFuel(vehicle)
			end
		end
	end
end)

function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, Config.FuelDecor, GetVehicleFuelLevel(vehicle))
	end
end

function GetFuel(vehicle)
	return DecorGetFloat(vehicle, Config.FuelDecor)
end

function Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)

	return math.floor(num * mult + 0.5) / mult
end
