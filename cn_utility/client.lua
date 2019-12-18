----- Closest Vehicle

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

function DoesEntityExistsAndIsNotNull(entity)
	return entity ~= nil and DoesEntityExist(entity)
end

function GetDistanceBetweenEntities(entity1, entity2)
	local entity1Coords = GetEntityCoords(entity1)
	local entity2Coords = GetEntityCoords(entity2)

	return GetDistanceBetweenCoords(entity1Coords.x, entity1Coords.y, entity1Coords.z, entity2Coords.x, entity2Coords.y, entity2Coords.z, true)
end

function GetDistanceToGround(entity)
	local entityCoords = GetEntityCoords(entity)
	local groundZ = 0
	GetGroundZFor_3dCoord(entityCoords.x, entityCoords.y, entityCoords.z, groundZ, false)

	return GetDistanceBetweenCoords(entityCoords.x, entityCoords.y, entityCoords.z, entityCoords.x, entityCoords.y, groundZ, true)
end

function GetModelHash(veh)
	return GetEntityModel(veh)
end

function IsVehicleDrivable(veh)
	if IsVehicleDriveable(veh, false) and
			(IsThisModelACar(GetModelHash(veh)) or
					IsThisModelABike(GetModelHash(veh)) or
					IsThisModelAQuadbike(GetModelHash(veh)) or
					IsThisModelAHeli(GetModelHash(veh)) or
					IsThisModelAPlane(GetModelHash(veh)) or
					IsThisModelABoat(GetModelHash(veh)) or
					IsThisModelABicycle(GetModelHash(veh))) then
		return true
	end

	return false
end

function GetClosestVehicleFromPedPos(ped, maxDistance, maxHeight, canReturnVehicleInside)
	local veh
	local smallestDistance = maxDistance
	local vehs = EnumerateVehicles()

	for vehi in EnumerateVehicles() do
		if (DoesEntityExistsAndIsNotNull(vehi) and (canReturnVehicleInside or IsPedInVehicle(ped, vehi, false) == false)) then
			local distance = GetDistanceBetweenEntities(ped, vehi);
			local height = GetDistanceToGround(vehi);
			if (distance <= smallestDistance and height <= maxHeight and height >= 0 and IsVehicleDrivable
			(vehi)) then
				smallestDistance = distance
				veh = vehi
			end
		end
	end

	return veh
end