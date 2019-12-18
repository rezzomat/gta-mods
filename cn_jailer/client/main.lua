ESX              = nil
local PlayerData = {}
local jailTime = 0

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

RegisterNetEvent('cn_jailer:jailPlayer')
AddEventHandler('cn_jailer:jailPlayer', function(newJailTime)
	local playerPed = PlayerPedId(-1)
	local time = newJailTime * Config.MonthLength
	print('called with ' .. time)
	SetEntityCoords(playerPed, Config.JailLocation.x, Config.JailLocation.y, Config.JailLocation.z)
	jailTime = time
	InJail()
end)

RegisterNetEvent('cn_jailer:unJailPlayer')
AddEventHandler('cn_jailer:unJailPlayer', function()
	jailTime = 0
end)

function InJail()
	Citizen.CreateThread(function()
		while jailTime > 0 do
			print(jailTime)
			Citizen.Wait(1000)
			jailTime = jailTime - 1

			if jailTime <= 0 then
				ESX.ShowNotification('Time is up, you are free to go.')
			end
		end
	end)
end

function UnJail()
	local playerPed = PlayerPedId(-1)
	SetEntityCoords(playerPed, Config.UnJailLocation.x, Config.UnJailLocation.y, Config.UnJailLocation.z)
end
