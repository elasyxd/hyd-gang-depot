local QBCore = exports['qb-core']:GetCoreObject()
local containerEntity = nil


local function SpawnDepotProp()
    local model = GetHashKey(Config.ContainerModel)
    
    local playerPed = PlayerPedId()
    local coords = Config.ContainerCoords
    local closestObj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, model, false, false, false)
    if closestObj ~= 0 then
        DeleteEntity(closestObj)
    end
    
    Wait(200)

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    
    if not HasModelLoaded(model) then
        return
    end

    containerEntity = CreateObject(model, coords.x, coords.y, coords.z, true, false, false)
    SetEntityHeading(containerEntity, coords.w)
    FreezeEntityPosition(containerEntity, true)
    SetEntityInvincible(containerEntity, true)
    PlaceObjectOnGroundProperly(containerEntity)
    SetModelAsNoLongerNeeded(model)
    
    exports['qb-target']:AddTargetEntity(containerEntity, {
        options = {
            {
                type = "client",
                event = "hyd-depot:unique:Open",
                icon = Config.Target.icon,
                label = Config.Target.label,
                gang = Config.Gang
            },
        },
        distance = 2.5
    })
end

CreateThread(function()
    Wait(1000)
    SpawnDepotProp()
end)


local function OpenCustomDepot()
    QBCore.Functions.TriggerCallback('hyd-gang-depot:server:GetDepotData', function(data)
        if data then
            Wait(200)
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "display",
                status = true
            })
            SendNUIMessage({
                action = "update",
                inventory = data.inventory,
                stash = data.stash,
                invWeights = data.invWeights,
                stashWeights = data.stashWeights
            })
        end
    end)
end

RegisterNetEvent('hyd-depot:unique:Open', function()
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    if PlayerData.gang.name ~= Config.Gang then
        QBCore.Functions.Notify("Bu depoya sadece Ballas üyeleri erişebilir!", "error")
        return
    end
    
    QBCore.Functions.TriggerCallback('hyd-gang-depot:server:GetPinStatus', function(hasPin)
        if not hasPin then
            local dialog = exports['qb-input']:ShowInput({
                header = "Depo Şifresi Belirle",
                submitText = "Şifreyi Kaydet",
                inputs = {
                    {
                        text = "Yeni Şifre (En az 6 haneli)",
                        name = "pin",
                        type = "number",
                        isRequired = true
                    }
                }
            })
            
            if dialog then
                local pin = tostring(dialog.pin)
                if #pin >= 6 then
                    TriggerServerEvent('hyd-gang-depot:server:SetPin', pin)
                else
                    QBCore.Functions.Notify("Şifre en az 6 haneli olmalıdır!", "error")
                end
            end
        else
            exports['hyd-keypad']:OpenKeypad(function(enteredPin)
                if enteredPin then
                    QBCore.Functions.TriggerCallback('hyd-gang-depot:server:VerifyAndOpen', function(success, message)
                        if success then
                            OpenCustomDepot()
                        else
                            QBCore.Functions.Notify(message or "Erişim reddedildi!", "error")
                        end
                    end, enteredPin)
                end
            end)
        end
    end)
end)



RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('transferItem', function(data, cb)
    TriggerServerEvent('hyd-gang-depot:server:TransferItem', data)
    cb('ok')
end)

RegisterNetEvent('hyd-gang-depot:client:RefreshUI', function()
    OpenCustomDepot()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if containerEntity and DoesEntityExist(containerEntity) then
            DeleteEntity(containerEntity)
        end
    end
end)

