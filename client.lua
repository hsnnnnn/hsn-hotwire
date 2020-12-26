ESX = nil 
Keys = {}
PlayerData = {}
SearchedVeh = {}
local disableF = false
Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports['es_extended']:getSharedObject()
        Citizen.Wait(1)
    end
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)
RegisterNetEvent('hsn-hotwire:client:addKeys')
AddEventHandler('hsn-hotwire:client:addKeys', function(data)
    Keys[data] = true
end)
RegisterNetEvent('hsn-hotwire:client:removeKeys')
AddEventHandler('hsn-hotwire:client:removeKeys',function(plate)
    Keys[plate] = nil
end)

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
	ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        local wait = 1000
        if IsPedInAnyVehicle(PlayerPedId(),false)  then
            local vehicle = GetVehiclePedIsIn(PlayerPedId())
            local Plate = GetVehicleNumberPlateText(vehicle)
            local vehicleCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 1.25, 0.35)
            if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then
                if Keys[Plate] ~= true then
                    wait = 2
                    if SearchedVeh[Plate] ~= true then
                        text = 'H - Ara | Z - Düz Kontak'
                    else
                        text = 'Z - Düzkontak'
                    end
                    if IsControlJustPressed(1, 20) then--z
                        local cancelled = exports['hsn-bar']:taskBar(2500,'Araç Maymuncuklanıyor 1/3')
                        if cancelled == 100 then
                            exports['hsn-bar']:taskBar(5000,'Araç Maymuncuklanıyor 2/3')
                            Citizen.Wait(15)
                            exports['hsn-bar']:taskBar(10000,'Araç Maymuncuklanıyor 3/3')
                            TriggerServerEvent('hsn-hotwire:addKeys',Plate)
                            SetVehicleEngineOn(vehicle,true)
                        end 
                        
                        
                    end
                    if IsControlJustPressed(1, 74) then --H
                        if SearchedVeh[Plate] ~= true then
                            SearchVehicle(Plate)
                        end
                    end
                    DrawText3Ds(vehicleCoords.x,vehicleCoords.y,vehicleCoords.z,text)
                end
            end
        end
        Citizen.Wait(wait)  
    end
end)

RegisterCommand('anahtarver', function()
    local vehicle = ESX.Game.GetVehicleInDirection()
    local Plate = GetVehicleNumberPlateText(vehicle)
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if vehicle ~= nil then
        if Keys[Plate] == true then
            if closestPlayer ~= -1 and closestDistance <= 3.0 then
                TriggerServerEvent('hsn-hotwire:server:giveKeys',GetPlayerServerId(closestPlayer), Plate)
            else
                TriggerEvent('notification', 'Yakında kimse yok',2)
            end
        else
            TriggerEvent('notification', 'Bu aracın anahtarlarına sahip değilsiniz',2)
        end
    else
        TriggerEvent('notification', 'Araca doğru bakmalısınız',2)
    end
end)
Citizen.CreateThread(function()
    while true do
        local wait = 750
        local veh = GetVehiclePedIsIn(PlayerPedId() , false)
        local Plate = GetVehicleNumberPlateText(veh)
        if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() and Keys[Plate] ~= true then
            wait = 6
            SetVehicleEngineOn(veh, false)
        end
        Citizen.Wait(wait)
    end
end)

SearchVehicle = function(plate)
    SearchedVeh[plate] = true
    local cancelled = exports['hsn-bar']:taskBar(1500,'Aranıyor 1/3')
    if cancelled == 100 then 
        Citizen.Wait(15)
        exports['hsn-bar']:taskBar(1500,'Aranıyor 2/3')
        Citizen.Wait(15)
        exports['hsn-bar']:taskBar(1500,'Aranıyor 3/3')
        TriggerServerEvent('hsn-hotwire:server:SearchVeh', plate)
    end   
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if IsControlJustPressed(1,182) then
            local coords = GetEntityCoords(PlayerPedId())
            vehicle = ESX.Game.GetClosestVehicle()
            local Plate = GetVehicleNumberPlateText(vehicle)
            if Keys[Plate] == true then
                local lock = GetVehicleDoorLockStatus(vehicle)
                if lock == 1 or lock == 0 then
                    TaskPlayAnim(PlayerPedId(), "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                    SetVehicleDoorShut(vehicle, 0, false)
                    SetVehicleDoorShut(vehicle, 1, false)
                    SetVehicleDoorShut(vehicle, 2, false)
                    SetVehicleDoorShut(vehicle, 3, false)
                    SetVehicleDoorsLocked(vehicle, 2)
                    PlayVehicleDoorCloseSound(vehicle, 1)
                    SetVehicleLights(vehicle, 2)
                    SetVehicleLights(vehicle, 0)
                    SetVehicleLights(vehicle, 2)
                    SetVehicleLights(vehicle, 0)
                    TriggerEvent('notification','Araç kilitlendi')
                elseif lock == 2 then
                    TaskPlayAnim(PlayerPedId(), "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                    SetVehicleDoorsLocked(vehicle, 1)
					PlayVehicleDoorOpenSound(vehicle, 0)
					SetVehicleLights(vehicle, 2)
					SetVehicleLights(vehicle, 0)
					SetVehicleLights(vehicle, 2)
                    SetVehicleLights(vehicle, 0)
                    TriggerEvent('notification','Araç kilidi açıldı')
                end
            end
        end
    end
end)
Citizen.CreateThread(function()
    while true do
        local wait = 1250
        if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 then 
            local curveh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            local pedDriver = GetPedInVehicleSeat(curveh, -1)
            local plate = GetVehicleNumberPlateText(curveh)
            if Keys[plate] ~= true and DoesEntityExist(pedDriver) and IsEntityDead(pedDriver) and not IsPedAPlayer(pedDriver)  then
                wait = 1
                exports["hsn-bar"]:taskBar(2000, 'Anahtar Alınıyor') 
                TriggerServerEvent('hsn-hotwire:addKeys',plate)
            end
        end
        Citizen.Wait(wait)
    end
end)

AddKeys = function(plate)
    if plate ~= nil then
        TriggerServerEvent('hsn-hotwire:addKeys',plate)
    end
end




