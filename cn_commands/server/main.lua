ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand('jail', function(source, args, raw)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer["job"]["name"] ~= 'police' then
		return
	end

	local jailPlayer = args[1]
	local jailTime = tonumber(args[2])

	if GetPlayerName(jailPlayer) ~= nil then
		if jailTime ~= nil then
			JailPlayer(jailPlayer, jailTime)
		end
	end
end)

RegisterCommand('unjail', function(source, args, raw)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer["job"]["name"] ~= 'police' then
		return
	end

	local jailPlayer = args[1]

	if GetPlayerName(jailPlayer) ~= nil then
		UnJailPlayer(jailPlayer)
	end
end)

function JailPlayer(jailPlayer, jailTime)
	TriggerClientEvent("cn_jailer:jailPlayer", jailPlayer, jailTime)

	-- EditJailTime(jailPlayer, jailTime)
end

function UnJailPlayer(jailPlayer)
	TriggerClientEvent("cn_jailer:unJailPlayer", jailPlayer)

	--EditJailTime(jailPlayer, 0)
end
