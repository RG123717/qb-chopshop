QBCore = exports['qb-core']:GetCoreObject()
local ChopShops = Config.ChopShops

local choppingInProgress = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)

		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		for i, chopShop in ipairs(ChopShops) do
			local distance = #(coords - chopShop.pos)

			if distance < 50 then
				DrawMarker(1, chopShop.pos.x, chopShop.pos.y, chopShop.pos.z - 0.99, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 150, false, true, 2, false, false, false, false)
			end

			if distance < 1.5 then
				DrawText3D(chopShop.pos.x, chopShop.pos.y, chopShop.pos.z, "[~g~E~s~] - Start Chopping")

				if IsControlJustReleased(0, 38) then
					local vehicle = GetVehiclePedIsIn(ped, false)

					if vehicle ~= 0 then
						TriggerServerEvent('lenzh_chopshop:server:RequestVehicle', i)
					else
						TriggerEvent('QBCore:Notify', "You are not in a vehicle.", "error")
					end
				end
			end
		end
	end
end)

RegisterNetEvent('lenzh_chopshop:client:SetVehicle')
AddEventHandler('lenzh_chopshop:client:SetVehicle', function(chopShopId, vehicle)
	local ped = PlayerPedId()
	local playerVehicle = GetVehiclePedIsIn(ped, false)

	if DoesEntityExist(playerVehicle) then
		if GetEntityModel(playerVehicle) == GetHashKey(vehicle) then
			local hasItems = false
			local requiredItems = Config.RequiredItems
			
			--for i=1, #illegalItems do
                --local hasItem = QBCore.Functions.HasItem(illegalItems[i])
                --if hasItem then
                    --print("dkhal w aando sleh")
                    --TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "RG", 1.0)
                    --TriggerServerEvent('police:server:policeAlert', 'Fama chkoun aando haja illeagal foukou')
                  --  Citizen.Wait(60000)
                --    break
              --  end
            --end

			for i=1, #requiredItems do
				print(requiredItems[i])
				local playerItem = QBCore.Functions.HasItem(requiredItems[i])
				print(playerItem)
				if playerItem then
					hasItems = true
					break
				end
			end

			if hasItems then
				StartChopping(chopShopId, playerVehicle)
			else
				TriggerEvent('QBCore:Notify', "You don't have the required items to start chopping.", "error")
			end
		else
			TriggerEvent('QBCore:Notify', "This is not the correct vehicle.", "error")
		end
	else
		TriggerEvent('QBCore:Notify', "You are not in a vehicle.", "error")
	end
end)

function StartChopping(chopShopId, vehicle)
    if not choppingInProgress then
        choppingInProgress = true

        -- Lock and disable controls while chopping
        SetVehicleDoorsLocked(vehicle, 2)
        TriggerEvent('lenzh_chopshop:client:ToggleControls', false)

        local timer = 30000
        QBCore.Functions.Progressbar("chopping_vehicle", "Chopping...", timer, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        })

        TriggerEvent('QBCore:Notify', "Chopping in progress...", "success")

        Citizen.Wait(timer)

        -- Unlock the vehicle and enable controls after chopping
        SetVehicleDoorsLocked(vehicle, 1)
        TriggerEvent('lenzh_chopshop:client:ToggleControls', true)

        -- Remove the vehicle and reward the player
        TriggerServerEvent('lenzh_chopshop:server:RemoveVehicle', chopShopId)
        TriggerServerEvent('lenzh_chopshop:server:rewardShit', chopShopId)
        DeleteVehicle(vehicle)

        TriggerEvent('QBCore:Notify', "You have successfully chopped the vehicle.", "success")
        choppingInProgress = false
    else
        TriggerEvent('QBCore:Notify', "Chopping is already in progress.", "error")
    end
end

function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local p = GetGameplayCamCoords()
	local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
	local scale = (1 / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	local scale = scale * fov
	if onScreen then
		SetTextScale(0.0, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
		DrawText(_x, _y)
		local factor = (string.len(text)) / 370
		DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
	end
end

RegisterNetEvent('lenzh_chopshop:client:ToggleControls')
AddEventHandler('lenzh_chopshop:client:ToggleControls', function(toggle)
	local ped = PlayerPedId()

	if not toggle then
		DisableControlAction(0, 75, true)
		DisableControlAction(27, 75, true)
		DisableControlAction(0, 22, true)
		DisableControlAction(0, 23, true)
		DisableControlAction(0, 288, true)
		DisableControlAction(0, 289, true)
		DisableControlAction(0, 170, true)
		DisableControlAction(0, 167, true)
		DisableControlAction(0, 73, true)
	else
		EnableControlAction(0, 75, true)
		EnableControlAction(27, 75, true)
		EnableControlAction(0, 22, true)
		EnableControlAction(0, 23, true)
		EnableControlAction(0, 288, true)
		EnableControlAction(0, 289, true)
		EnableControlAction(0, 170, true)
		EnableControlAction(0, 167, true)
		EnableControlAction(0, 73, true)
	end
end)

