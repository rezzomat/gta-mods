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

RegisterCommand('sv', function(source, args, raw)
	local playerPed = PlayerPedId()
	local index = tonumber(args[1])

	if PlayerData.job == nil then
		PlayerData = ESX.GetPlayerData()
	end

	if PlayerData.job.name ~= 'police' then
		return
	end

	local car = Config.AuthorizedVehicles[PlayerData.job.name][index]
	print(ESX.DumpTable(car))
	print(car.model)
	print(PlayerData.job.grade)

	if PlayerData.job.grade < car.grade then
		return
	end

	ESX.Game.SpawnVehicle(car.model, GetEntityCoords(PlayerPedId(-1)), 100, function(vehicle)
		TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		vehicleProps['fuelLevel'] = 100.0
		if car.livery ~= nil then
			SetVehicleLivery(vehicle, car.livery)
		end
		if Config.EnableOwnedVehicles then
			TriggerServerEvent('cn_commands:setVehicleOwned', vehicleProps, PlayerData.job.name)
		end
	end)
end)

RegisterCommand('impound', function(source, args, raw)
	local playerPed = PlayerPedId()

	if PlayerData.job == nil then
		PlayerData = ESX.GetPlayerData()
	end

	if PlayerData.job.name ~= 'police' then
		return
	end

	local vehicle = exports['cn_utility']:GetClosestVehicleFromPedPos(playerPed, 500.0, 50.0, false)
	local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
	local plate = vehicleProps.plate

	ESX.Game.DeleteVehicle(vehicle)

	if Config.EnableOwnedVehicles then
		TriggerServerEvent('cn_commands:removeVehicleOwned', plate, PlayerData.job.name)
	end

end)
