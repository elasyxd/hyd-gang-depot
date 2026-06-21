local currentCallback = nil

local function OpenKeypad(callback)
    currentCallback = callback
    SetNuiFocus(true, true)
    SendNUIMessage({
        open = true
    })
end

exports('OpenKeypad', OpenKeypad)

RegisterNUICallback('close', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)
    if currentCallback then
        currentCallback(false) -- İşlem iptal edildi
        currentCallback = nil
    end
end)

RegisterNUICallback('complete', function(data, cb)
    cb('ok')
    SetNuiFocus(false, false)
    if currentCallback then
        currentCallback(data.pin) -- Girilen pin'i gönder
        currentCallback = nil
    end
end)

