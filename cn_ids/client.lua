ESX              = nil
local idControlPresse = false

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

function DrawText3Ds(x,y,z, text, withRect)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())

	SetTextScale(0.5, 0.5)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	if withRect then
		DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
	end
end

Citizen.CreateThread(function()
	local _players = {}
	while true do
		ESX.TriggerServerCallback('cn_ids:getOnlinePlayers', function(players)
			_players = players
		end)
		if IsControlPressed(0, 73) then
			Citizen.Wait(0)
			for i=1, #_players, 1 do
				local id = GetPlayerFromServerId(_players[i].source)
				local ped = GetPlayerPed(id)
				local coord = GetEntityCoords(ped)

				DrawText3Ds(coord.x, coord.y, coord.z+1, '(' .. _players[i].source .. ')', false)
			end
		else
			Citizen.Wait(1000)
		end
	end
end)
