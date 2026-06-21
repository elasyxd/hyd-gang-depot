local QBCore = exports['qb-core']:GetCoreObject()
local currentPin = nil

Citizen.CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do Wait(100) end
    
    exports.ox_inventory:RegisterStash(Config.Stash.id, Config.Stash.label, Config.Stash.slots, Config.Stash.maxWeight)
    
    exports.oxmysql:query([[
        CREATE TABLE IF NOT EXISTS `hyd_gang_depots` (
            `depot_id` VARCHAR(50) NOT NULL,
            `pin` VARCHAR(50) DEFAULT NULL,
            PRIMARY KEY (`depot_id`)
        );
    ]])

    local result = exports.oxmysql:scalarSync('SELECT pin FROM hyd_gang_depots WHERE depot_id = ?', {Config.Stash.id})
    if result then
        currentPin = tostring(result)
    end
end)
QBCore.Functions.CreateCallback('hyd-gang-depot:server:GetPinStatus', function(source, cb)
    cb(currentPin ~= nil)
end)

RegisterNetEvent('hyd-gang-depot:server:SetPin', function(newPin)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.gang.name == Config.Gang then
        currentPin = tostring(newPin)
        exports.oxmysql:insert('INSERT INTO hyd_gang_depots (depot_id, pin) VALUES (?, ?) ON DUPLICATE KEY UPDATE pin = ?', {Config.Stash.id, newPin, newPin})
        TriggerClientEvent('QBCore:Functions:Notify', src, "Şifre başarıyla kaydedildi.", "success")
    end
end)

local function formatItems(items)
    local formatted = {}
    local imageBase = "nui://" .. GetCurrentResourceName() .. "/html/img/"
    
    for _, item in pairs(items) do
        local cfg = Config.Items[item.name:lower()] or {}
        local finalImage = cfg.img or (item.name .. ".webp")
        if not finalImage:find("%.") then finalImage = finalImage .. ".webp" end
        
        table.insert(formatted, { 
            name = item.name, 
            label = cfg.label or item.label, 
            count = item.count, 
            weight = item.weight, 
            image = imageBase .. finalImage, 
            rarity = (item.metadata and item.metadata.rarity) or cfg.rarity or "COMMON" 
        })
    end
    return formatted
end

QBCore.Functions.CreateCallback('hyd-gang-depot:server:GetDepotData', function(source, cb)
    local playerInv = exports.ox_inventory:GetInventory(source)
    local stashInv = exports.ox_inventory:GetInventory(Config.Stash.id)
    
    if not playerInv or not stashInv then return cb(false) end

    cb({
        inventory = formatItems(playerInv.items),
        stash = formatItems(stashInv.items),
        invWeights = { current = math.max(0, playerInv.weight / 1000), max = playerInv.maxWeight / 1000 },
        stashWeights = { current = math.max(0, stashInv.weight / 1000), max = (stashInv.maxWeight or Config.Stash.maxWeight) / 1000 }
    })
end)

RegisterNetEvent('hyd-gang-depot:server:TransferItem', function(data)
    local src = source
    local from, itemName, count = data.from, data.name, data.count or 1
    if from == 'inventory' then
        if exports.ox_inventory:CanCarryItem(Config.Stash.id, itemName, count) then
            exports.ox_inventory:RemoveItem(src, itemName, count)
            exports.ox_inventory:AddItem(Config.Stash.id, itemName, count)
            TriggerClientEvent('hyd-gang-depot:client:RefreshUI', src)
        end
    else
        if exports.ox_inventory:CanCarryItem(src, itemName, count) then
            exports.ox_inventory:RemoveItem(Config.Stash.id, itemName, count)
            exports.ox_inventory:AddItem(src, itemName, count)
            TriggerClientEvent('hyd-gang-depot:client:RefreshUI', src)
        end
    end
end)

QBCore.Functions.CreateCallback('hyd-gang-depot:server:VerifyAndOpen', function(source, cb, enteredPin)
    if tostring(enteredPin) == tostring(currentPin) then cb(true) else cb(false, "Hatalı şifre!") end
end)


