
Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId(-1)
		Citizen.Wait(0)
		if (IsPedInAnyVehicle(ped)) then
		local veh = GetVehiclePedIsIn(ped)
			-- Disable air control
			if IsEntityInAir(veh) then
				DisableControlAction(0, 59, true)
				DisableControlAction(0, 60, true)
			end

			-- Vehicle roll
			local roll = GetEntityRoll(veh)
			if (roll > 75.0 or roll < -75.0) then
				DisableControlAction(2,59,true)
				DisableControlAction(2,60,true)
			end
		end
	end
end)