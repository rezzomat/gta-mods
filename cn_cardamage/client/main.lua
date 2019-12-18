ESX              = nil
local PlayerData = {}
local CurrentAction = nil

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

RegisterCommand('repair', function(source, args, raw)
	local playerPed = PlayerPedId(-1)
	local vehicle = exports['cn_utility']:GetClosestVehicleFromPedPos(playerPed, 3.0, 50.0, false)
	local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
	local isTyreBurst = IsVehicleTyreBurst(vehicle, 0, true) or IsVehicleTyreBurst(vehicle, 1, true)
	local tyreAffected
	if IsVehicleTyreBurst(vehicle, 0, true) then
		tyreAffected = 0
	elseif IsVehicleTyreBurst(vehicle, 1, true) then
		tyreAffected = 1
	end
	if isTyreBurst then
		print('need repairing')
	else
		print('no rapair needed')
		return
	end
	exports['progressBars']:startUI(5000, "Reparing")
	ESX.Streaming.RequestAnimDict("mini@repair", function()
		print('hello')
		TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 2.0, -2.0, 5000, 49, 0, true, false, true)
	end)
	Citizen.Wait(5000)
	SetVehicleTyreFixed(vehicle, tyreAffected)
	SetVehicleUndriveable(vehicle, false)
	SetVehicleEngineOn(vehicle, true, false)

	while (not HasAnimDictLoaded("random@arrests@busted")) do Citizen.Wait(10) end
	TaskPlayAnim(playerPed, "mini@repair", "fixing_a_car", 2.0, -2.0, -1, 49, 0, true, false, true)

end)


-- RegisterNetEvent('cn_cardamage:onUse')
-- AddEventHandler('cn_cardamage:onUse', function()local playerPed = PlayerPedId(-1)
-- 	local vehicle = exports['cn_utility']:GetClosestVehicleFromPedPos(playerPed, 3.0, 50.0, false)
-- 	local isTyreBurst = IsVehicleTyreBurst(vehicle, 0, true) or IsVehicleTyreBurst(vehicle, 1, true)
-- 	local isFrontLeft = IsVehicleTyreBurst(vehicle, 0, true)
-- 	local isFrontRight = IsVehicleTyreBurst(vehicle, 1, true)
-- 	local repairTime = Config.RepairTime * 1000

-- 	if isTyreBurst then
-- 		print('need repairing')
-- 	else
-- 		print('no rapair needed')
-- 		return
-- 	end

-- 	exports['progressBars']:startUI(repairTime, "Reparing")
-- 	ESX.Streaming.RequestAnimDict("mini@repair", function()
-- 		print('hello')
-- 		TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_ped", 2.0, -2.0, repairTime, 49, 0, true, false, true)
-- 	end)
-- 	Citizen.Wait(repairTime)

-- 	if isFrontLeft then
-- 		SetVehicleTyreFixed(vehicle, 0)
-- 	end
-- 	if isFrontRight then
-- 		SetVehicleTyreFixed(vehicle, 1)
-- 	end
-- 	SetVehicleUndriveable(vehicle, false)
-- 	SetVehicleEngineOn(vehicle, true, false)

-- 	if Config.ConsumeRepairKit then
-- 		TriggerServerEvent('cn_repairkit:removeKit')
-- 	end
-- end)

Citizen.CreateThread(function()
	local vehicleBodyHealth
	local vehicleEngineHealth
	local vehicleTankHealth
	local bodyHealthDelta
	local engineHealthDelta
	local tankHealthDelta
	local vehicle
	local vehicleClass
	local playerPed = PlayerPedId(-1)
	while true do
		Citizen.Wait(500)
		if IsPedInAnyVehicle(playerPed) then
			vehicle = GetVehiclePedIsIn(playerPed, false)
			vehicleClass = GetVehicleClass(vehicle)

			if GetPedInVehicleSeat(vehicle, -1) == playerPed then

				if vehicleBodyHealth == nil then
					vehicleEngineHealth = GetVehicleEngineHealth(vehicle)
					vehicleTankHealth = GetVehiclePetrolTankHealth(vehicle)
					vehicleBodyHealth = GetVehicleBodyHealth(vehicle)
					print('reset')
				else
					-- Body
					local newBodyHealth = GetVehicleBodyHealth(vehicle)
					bodyHealthDelta = (vehicleBodyHealth - newBodyHealth) * Config.BodyHealthFactor * Config.HealthFactorForClass[vehicleClass]
					print(bodyHealthDelta)
					if bodyHealthDelta > Config.BodyHealthThreshold then
						local tireAffected = math.random(0,1)  -- random front tire
						SetVehicleTyreBurst(vehicle, tireAffected, true, 1000.0)
						SetVehicleUndriveable(vehicle, true)
					end

					-- Engine
					local newEngineHealth = GetVehicleEngineHealth(vehicle)
					engineHealthDelta = (vehicleEngineHealth - newEngineHealth) * Config.EngineHealthFactor * Config.HealthFactorForClass[vehicleClass]
					if engineHealthDelta > Config.EngineHealthThreshold then
						local tireAffected = math.random(0,1)  -- random front tire
						SetVehicleTyreBurst(vehicle, tireAffected, true, 1000.0)
						SetVehicleUndriveable(vehicle, true)
					end

					-- Tank
					local newTankHealth = GetVehiclePetrolTankHealth(vehicle)
					tankHealthDelta = (vehicleTankHealth - newTankHealth) * Config.TankHealthFactor * Config.HealthFactorForClass[vehicleClass]
					if tankHealthDelta > Config.TankHealthThreshold then
						local tireAffected = math.random(0,1)  -- random front tire
						SetVehicleTyreBurst(vehicle, tireAffected, true, 1000.0)
						SetVehicleUndriveable(vehicle, true)
					end

					vehicleBodyHealth = newBodyHealth
					vehicleEngineHealth = newEngineHealth
					vehicleTankHealth = newTankHealth

				end
			end
		else
			vehicleBodyHealth = nil
			bodyHealthDelta = 0
			vehicleEngineHealth = nil
			engineHealthDelta = 0
			vehicleTankHealth = nil
			tankHealthDelta = 0
		end
	end
end)
