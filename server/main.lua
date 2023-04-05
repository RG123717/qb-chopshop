QBCore = exports['qb-core']:GetCoreObject()

local chopshopActive = {}

RegisterServerEvent('lenzh_chopshop:server:RequestVehicle')
AddEventHandler('lenzh_chopshop:server:RequestVehicle', function(chopShopId)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	
	if not chopshopActive[chopShopId] then
		chopshopActive[chopShopId] = true

		local vehicle = Config.ChopShops[chopShopId].vehicle

		TriggerClientEvent('lenzh_chopshop:client:SetVehicle', src, chopShopId, vehicle)
	else
		TriggerClientEvent('QBCore:Notify', src, 'This chop shop is currently occupied.', 'error')
	end
end)

RegisterServerEvent('lenzh_chopshop:server:RemoveVehicle')
AddEventHandler('lenzh_chopshop:server:RemoveVehicle', function(chopShopId)
	chopshopActive[chopShopId] = false
end)

RegisterServerEvent('lenzh_chopshop:server:rewardShit')
AddEventHandler('lenzh_chopshop:server:rewardShit', function(chopShopId)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local payout = math.random(Config.ChopShops[chopShopId].payout[1], Config.ChopShops[chopShopId].payout[2])

	Player.Functions.AddMoney('cash', payout)
	TriggerClientEvent('QBCore:Notify', src, 'You received $' .. payout .. ' for delivering the vehicle.', 'success')
end)
