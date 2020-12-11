SearchedVehicles = {}
ESX = nil 
TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

RegisterServerEvent('hsn-hotwire:addKeys')
AddEventHandler('hsn-hotwire:addKeys',function(plate)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    TriggerClientEvent('hsn-hotwire:client:addKeys',src,plate)
end)
RegisterServerEvent('hsn-hotwire:server:giveKeys')
AddEventHandler('hsn-hotwire:server:giveKeys',function(target,plate)
    local src = source
    local tPlayer = ESX.GetPlayerFromId(target)
    TriggerClientEvent('hsn-hotwire:client:removeKeys',src,plate)
    TriggerClientEvent('hsn-hotwire:client:addKeys',tPlayer.source,plate)
end)
RegisterServerEvent('hsn-hotwire:server:SearchVeh')
AddEventHandler('hsn-hotwire:server:SearchVeh',function(plate)
    local src = source 
    --local Items = ESX.GetItems()
    local Player = ESX.GetPlayerFromId(src)
    if SearchedVehicles[plate] ~= true then
        SearchedVehicles[plate] = true
        local luck = math.random(3)
        if luck == 1 then
            Player.addInventoryItem('bread',1)
        elseif luck == 2 then
            Player.addInventoryItem('water',1)
        elseif luck == 3 then
            Player.addInventoryItem('weapon_snspistol',1)
        end    
    else
        TriggerClientEvent('notification', src, plate..' plakalı aracın torpidosu zaten daha önceden aranmış',2)        
    end 
end)
