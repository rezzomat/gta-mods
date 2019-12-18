ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('cn_blips:spawned')
AddEventHandler('cn_blips:spawned', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	Citizen.Wait(5000)
	TriggerClientEvent('cn_blips:updateBlip', -1)
end)

RegisterServerEvent('cn_blips:addBlip')
AddEventHandler('cn_blips:addBlip', function(ped)
	Citizen.Wait(500)
	TriggerClientEvent('cn_blips:addBlip', -1, ped)
end)

RegisterServerEvent('cn_blips:removeBlip')
AddEventHandler('cn_blips:removeBlip', function(ped)
	Citizen.Wait(500)
	TriggerClientEvent('cn_blips:removeBlip', -1, ped)
end)

ESX.RegisterServerCallback('cn_blips:getOnlinePlayers', function(source, cb)
	local xPlayers = ESX.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name,
			job        = xPlayer.job
		})
	end

	cb(players)
end)