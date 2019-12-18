ESX              = nil
local PlayerData = {}
local CurrentAction = nil
local hasAlreadyJoined = false

local BlipsId = {}
local blipsCops = {}

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

function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		--ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('cn_blips:updateBlip')
AddEventHandler('cn_blips:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Is the player a cop? In that case show all the blips for other cops

	local ped = PlayerPedId(-1)

	if has_value(BlipsId, ped) then
		ESX.TriggerServerCallback('cn_blips:getOnlinePlayers', function(players)
			for i=1, #players, 1 do

				local id = GetPlayerFromServerId(players[i].source)
				if NetworkIsPlayerActive(id) and has_value(BlipsId, GetPlayerPed(id)) then
					createBlip(id)
				end

			end
		end)
	end
end)

AddEventHandler('playerSpawned', function(spawn)

	if not hasAlreadyJoined then
		TriggerServerEvent('cn_blips:spawned')
	end
	hasAlreadyJoined = true
end)

function has_value (tab, val)
	for index, value in ipairs(tab) do
		if tostring(value) == tostring(val) then
			return true
		end
	end

	return false
end

Citizen.CreateThread(function()
	while not hasAlreadyJoined do
		Citizen.Wait(500)
		hasAlreadyJoined = true
		TriggerServerEvent('cn_blips:spawned')
	end
end)

RegisterNetEvent('cn_blips:removeBlip')
AddEventHandler('cn_blips:removeBlip', function(id)
	print('removed ' .. id .. ' from table')
	remove(BlipsId, tostring(id))
	TriggerServerEvent('cn_blips:spawned')
end)

RegisterNetEvent('cn_blips:addBlip')
AddEventHandler('cn_blips:addBlip', function(id)
	table.insert(BlipsId, tostring(id))
	print('added ' .. id .. ' to table')
	TriggerServerEvent('cn_blips:spawned')
end)

RegisterCommand('add', function(source, args, raw)
	local ped = PlayerPedId(-1)

	local pedToAdd = ped

	if args[1] ~= nil then
		pedToAdd = args[1]
	end

	TriggerServerEvent('cn_blips:addBlip', pedToAdd)
end)

RegisterCommand('remove', function(source, args, raw)
	local ped = PlayerPedId(-1)

	local pedToRemove = ped

	if args[1] ~= nil then
		pedToRemove = args[1]
	end

	TriggerServerEvent('cn_blips:removeBlip', pedToRemove)
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

RegisterCommand('id', function(source, args, raw)
	ESX.TriggerServerCallback('cn_blips:getOnlinePlayers', function(players)
		print(ESX.DumpTable(players))
		for i=1, #players, 1 do

			local id = GetPlayerFromServerId(players[i].source)
			local ped = GetPlayerPed(id)
			local coord = GetEntityCoords(ped)
			print(ESX.DumpTable(coord))

			print(ESX.DumpTable(ped))
		end
	end)
end)

function remove(tab, value)
	for i=1, #tab do
		if tab[i] == value then
			table.remove(tab, i)
			return
		end
	end
end


Citizen.CreateThread(function()
	local _players = {}
	while true do
		Citizen.Wait(0)
		ESX.TriggerServerCallback('cn_blips:getOnlinePlayers', function(players)
			_players = players
		end)
		if IsControlPressed(0, 73) then
			for i=1, #_players, 1 do
				local id = GetPlayerFromServerId(_players[i].source)
				local ped = GetPlayerPed(id)
				local coord = GetEntityCoords(ped)

				DrawText3Ds(coord.x, coord.y, coord.z+1, '(' .. _players[i].source .. ')', false)
			end
		end
	end
end)
