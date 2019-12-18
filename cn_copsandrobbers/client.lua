ESX              = nil
local PlayerData = {}
local CurrentAction = nil
local hasAlreadyJoined = false
local index = 1
local copIndex = 1
local robberIndex = 1

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

-- Utility

function has_value (tab, val)
	for index, value in ipairs(tab) do
		if tostring(value) == tostring(val) then
			return true
		end
	end

	return false
end

function remove(tab, value)
	for i=1, #tab do
		if tab[i] == value then
			table.remove(tab, i)
			return
		end
	end
end

function DrawText3Ds(x,y,z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())

	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 370
	DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

function setUniform(job, playerPed)
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Locations[job].Uniform.male then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Locations[job].Uniform.male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			if Config.Locations[job].Uniform.female then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Locations[job].Uniform.female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		end
	end)
end

-- Events

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

AddEventHandler('tps:teleport', function(destination, skin)
	local x = destination["x"]
	local y = destination["y"]
	local z = destination["z"]

	RequestCollisionAtCoord(x, y, z)

	while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
		RequestCollisionAtCoord(x, y, z)
		Citizen.Wait(1)
	end

	SetEntityCoords(PlayerPedId(), x, y, z)
	TriggerEvent('skinchanger:loadSkin', skin)
end)

AddEventHandler('tps:hasExitedMarker', function()
	-- Nothing
end)

-- Commands

-- Loops

Citizen.CreateThread(function()
	while not hasAlreadyJoined do
		Citizen.Wait(500)
		PlayerData = ESX.GetPlayerData()
		hasAlreadyJoined = true
	end
end)


Citizen.CreateThread(function()

	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local isInMarker, hasExited = false, false
		local destination, label, location, outfit, models, model

		for k,v in pairs(Config.Locations) do
			for i=1, #v.Marker, 1 do

				local distance = #(coords - v.Marker[i])

				if distance < Config.DrawDistance then
					DrawMarker(27, v.Marker[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 30, false, true, 2, false, false, false, false)
				end

				if distance < Config.MarkerSize.x then
					isInMarker, destination, label, location, outfit, models = true, v.Spawns, v.label, v.Marker[i], v.Uniform, v.model
					if label == 'Police' then
						model = models[copIndex]
						GiveWeaponToPed(playerPed, 'WEAPON_STUNGUN', 100, false, false)
					end
					if label == 'Robber' then
						model = models[robberIndex]
					end
				end
			end
		end

		if isInMarker then
			DrawText3Ds(location["x"], location["y"], location["z"], "Press [E] to enter as a " .. label .. "    Press [F](+) or [G](-) to change model: ".. model)
		end

		if isInMarker and IsControlJustReleased(0, 38) then
			for k, v in pairs(destination) do
				local isFree = ESX.Game.IsSpawnPointClear(v, 1)
				if isFree then
					setUniform(label, playerPed)
					RemoveAllPedWeapons(playerPed, false)
					if label == 'Police' then
						model = models[copIndex]
						GiveWeaponToPed(playerPed, 'WEAPON_STUNGUN', 100, false, false)
					end
					if label == 'Robber' then
						model = models[robberIndex]
					end

					ESX.Game.SpawnVehicle(model, v, v.w, function(vehicle)
						TaskWarpPedIntoVehicle(playerPed,  vehicle, -1)
					end)
					break
				else
					print("spawn point not clear")
				end
			end
		end
		if isInMarker and IsControlJustReleased(0, 23) then
			if label == 'Police' then
				copIndex = copIndex + 1
				if copIndex > #models then
					copIndex = 1
				end
			end
			if label == 'Robber' then
				robberIndex = robberIndex + 1
				if robberIndex > #models then
					robberIndex = 1
				end
			end
		end
		if isInMarker and IsControlJustReleased(0, 47) then
			if label == 'Police' then
				copIndex = copIndex - 1
				if copIndex < 1 then
					copIndex = #models
				end
			end
			if label == 'Robber' then
				robberIndex = robberIndex - 1
				if robberIndex < 1 then
					robberIndex = #models
				end
			end
		end

	end

end)
