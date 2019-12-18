ESX              = nil
local PlayerData = {}
_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu('Devs', 'Development menu')
_menuPool:Add(mainMenu)
_menuPool:MouseControlsEnabled(false)
_menuPool:MouseEdgeEnabled(false)

local isDebug = false

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

-- Menu

function AddMenuSpawner(menu)
	local options = {'zentorno', 'adder', 'kuruma'}
	local newitem = NativeUI.CreateListItem('Cars', options, 1)
	menu:AddItem(newitem)
	--menu.OnListChange = function(sender, item, index)
	--	if item == newitem then
	--		car = item:IndexToItem(index)
	--		print(car)
	--	end
	--end
	menu.OnItemSelect = function(sender, item, index)
		print('select')
		if item == newitem then
			car_model = item:IndexToItem(index)
			print(car_model)
		end
	end
end

AddMenuSpawner(mainMenu)
_menuPool:RefreshIndex()

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		_menuPool:ProcessMenus()
		if IsControlJustPressed(1, 56) then
			print('pressed')
			mainMenu:Visible(not mainMenu:Visible())
		end
	end
end)

-- Helpers

function drawTxt(x,y ,width,height,scale, text, r,g,b,a)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(0.25, 0.25)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
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

function GetVehicle()
	local playerped = GetPlayerPed(-1)
	local playerCoords = GetEntityCoords(playerped)
	local handle, ped = FindFirstVehicle()
	local success
	local rped = nil
	local distanceFrom
	repeat
		local pos = GetEntityCoords(ped)
		local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
		if canPedBeUsed(ped) and distance < 30.0 and (distanceFrom == nil or distance < distanceFrom) then
			distanceFrom = distance
			rped = ped
			-- FreezeEntityPosition(ped, inFreeze)
			if IsEntityTouchingEntity(GetPlayerPed(-1), ped) then
				DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Veh: " .. ped .. " Model: " .. GetEntityModel(ped) .. " IN CONTACT" )
			else
				DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Veh: " .. ped .. " Model: " .. GetEntityModel(ped) .. "" )
			end
			if lowGrav then
				SetEntityCoords(ped,pos["x"],pos["y"],pos["z"]+5.0)
			end
		end
		success, ped = FindNextVehicle(handle)
	until not success
	EndFindVehicle(handle)
	return rped
end

function GetObject()
	local playerped = GetPlayerPed(-1)
	local playerCoords = GetEntityCoords(playerped)
	local handle, ped = FindFirstObject()
	local success
	local rped = nil
	local distanceFrom
	repeat
		local pos = GetEntityCoords(ped)
		local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
		if distance < 10.0 then
			distanceFrom = distance
			rped = ped
			--FreezeEntityPosition(ped, inFreeze)
			if IsEntityTouchingEntity(GetPlayerPed(-1), ped) then
				DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Obj: " .. ped .. " Model: " .. GetEntityModel(ped) .. " IN CONTACT" )
			else
				DrawText3Ds(pos["x"],pos["y"],pos["z"]+1, "Obj: " .. ped .. " Model: " .. GetEntityModel(ped) .. "" )
			end

			if lowGrav then
				--ActivatePhysics(ped)
				SetEntityCoords(ped,pos["x"],pos["y"],pos["z"]+0.1)
				FreezeEntityPosition(ped, false)
			end
		end

		success, ped = FindNextObject(handle)
	until not success
	EndFindObject(handle)
	return rped
end

function getNPC()
	local playerped = GetPlayerPed(-1)
	local playerCoords = GetEntityCoords(playerped)
	local handle, ped = FindFirstPed()
	local success
	local rped = nil
	local distanceFrom
	repeat
		local pos = GetEntityCoords(ped)
		local distance = GetDistanceBetweenCoords(playerCoords, pos, true)
		if canPedBeUsed(ped) and distance < 30.0 and (distanceFrom == nil or distance < distanceFrom) then
			distanceFrom = distance
			rped = ped

			if IsEntityTouchingEntity(GetPlayerPed(-1), ped) then
				DrawText3Ds(pos["x"],pos["y"],pos["z"], "Ped: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Relationship HASH: " .. GetPedRelationshipGroupHash(ped) .. " IN CONTACT" )
			else
				DrawText3Ds(pos["x"],pos["y"],pos["z"], "Ped: " .. ped .. " Model: " .. GetEntityModel(ped) .. " Relationship HASH: " .. GetPedRelationshipGroupHash(ped) )
			end

			FreezeEntityPosition(ped, inFreeze)
			if lowGrav then
				SetPedToRagdoll(ped, 511, 511, 0, 0, 0, 0)
				SetEntityCoords(ped,pos["x"],pos["y"],pos["z"]+0.1)
			end
		end
		success, ped = FindNextPed(handle)
	until not success
	EndFindPed(handle)
	return rped
end

-- Command and loop

RegisterCommand('devm', function(source, args, raw)
	mainMenu:Visible(true)
end)

RegisterCommand('dev', function(source, args, raw)
	isDebug = not isDebug
end)

Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

		if isDebug then
			local ped = GetPlayerPed(-1)
			local coord = GetEntityCoordsf(ped)
			local x, y, z = table.unpack(coord)
			local heading = GetEntityHeading(ped)
			local attachedEntity = GetEntityAttachedTo(ped)
			local health = GetEntityHealth(ped)
			local height = GetEntityHeightAboveGround(ped)
			local model = GetEntityModel(ped)
			local speed = GetEntitySpeed(ped)
			local frameTime = GetFrameTime()
			local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z, currentStreetHash, intersectStreetHash)
			local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)

			drawTxt(0.8, 0.50, 0.4,0.4,0.30, "Heading: " .. heading, 55, 155, 55, 255)
			drawTxt(0.8, 0.52, 0.4,0.4,0.30, "Coords: " .. coord, 55, 155, 55, 255)
			drawTxt(0.8, 0.54, 0.4,0.4,0.30, "Attached Ent: " .. attachedEntity, 55, 155, 55, 255)
			drawTxt(0.8, 0.56, 0.4,0.4,0.30, "Health: " .. health, 55, 155, 55, 255)
			drawTxt(0.8, 0.58, 0.4,0.4,0.30, "H a G: " .. height, 55, 155, 55, 255)
			drawTxt(0.8, 0.60, 0.4,0.4,0.30, "Model: " .. model, 55, 155, 55, 255)
			drawTxt(0.8, 0.62, 0.4,0.4,0.30, "Speed: " .. speed, 55, 155, 55, 255)
			drawTxt(0.8, 0.64, 0.4,0.4,0.30, "Frame Time: " .. frameTime, 55, 155, 55, 255)
			drawTxt(0.8, 0.66, 0.4,0.4,0.30, "Street: " .. currentStreetName, 55, 155, 55, 255)

			if IsPedInAnyVehicle(ped, false) then
				local vehicle = GetVehiclePedIsIn(ped, false)
				local vehicleBodyHealth = GetVehicleBodyHealth(vehicle)
				local vehicleEngineHealth = GetVehicleEngineHealth(vehicle)
				drawTxt(0.8, 0.68, 0.4,0.4,0.30, "VBH: " .. vehicleBodyHealth, 55, 155, 55, 255)
				drawTxt(0.8, 0.70, 0.4,0.4,0.30, "VEH: " .. vehicleEngineHealth, 55, 155, 55, 255)
			end

		else
			Citizen.Wait(5000)
		end
	end
end)