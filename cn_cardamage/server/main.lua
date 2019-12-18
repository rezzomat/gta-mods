ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Make the kit usable!
ESX.RegisterUsableItem('repairkit', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if Config.AllowMecano then
		TriggerClientEvent('cn_cardamage:onUse', _source)
	else
		if xPlayer.job.name ~= 'mecano' then
			TriggerClientEvent('cn_cardamage:onUse', _source)
		end
	end
end)

RegisterNetEvent('cn_cardamage:removeKit')
AddEventHandler('cn_cardamage:removeKit', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if not Config.InfiniteRepairs then
		xPlayer.removeInventoryItem('repairkit', 1)
		TriggerClientEvent('esx:showNotification', _source, _U('used_kit'))
	end
end)
