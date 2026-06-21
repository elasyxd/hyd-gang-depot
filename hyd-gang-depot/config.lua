Config = {}

Config.Gang = "ballas" -- Restricted gang name
Config.ContainerModel = "prop_container_05mb" -- More standard GTA model
Config.ContainerCoords = vector4(139.75, -1928.81, 20.95, 319.4)

Config.Stash = {
    id = "ballas_depot_v2",
    label = "Ballas Özel Depo",
    slots = 50,
    maxWeight = 100000, -- 100kg
}

Config.Keypad = {
    correctPin = nil,
}

Config.Target = {
    label = "Depoya Eriş",
    icon = "fas fa-warehouse"
}

Config.Items = {
    ["money"] = { label = "Para", img = "money.webp", rarity = "COMMON" },
    ["ammo-9"] = { label = "9mm Mermi", img = "ammo-9.webp", rarity = "COMMON" },
    ["phone"] = { label = "Telefon", img = "iphone.webp", rarity = "COMMON" },
    ["armor"] = { label = "Zırh", img = "armor.webp", rarity = "EPIC" },
    
    ["weapon_pistol"] = { label = "Pistol", img = "WEAPON_PISTOL.webp", rarity = "UNCOMMON" },
    ["weapon_carbinerifle"] = { label = "Carbine Rifle", img = "WEAPON_CARBINERIFLE.webp", rarity = "EPIC" },
    ["weapon_smg"] = { label = "SMG", img = "WEAPON_SMG.webp", rarity = "UNCOMMON" },
    
    ["bandage"] = { label = "Bandaj", img = "bandage.webp", rarity = "COMMON" },
    ["medkit"] = { label = "İlkyardım Kiti", img = "firstaid.webp", rarity = "RARE" },
    ["ifaks"] = { label = "IFAK", img = "ifak.webp", rarity = "RARE" },
    
    ["lockpick"] = { label = "Maymuncuk", img = "lockpick.webp", rarity = "UNCOMMON" },
    ["advancedlockpick"] = { label = "Gelişmiş Maymuncuk", img = "advancedlockpick.webp", rarity = "RARE" },
    ["radio"] = { label = "Radyo", img = "radio.webp", rarity = "UNCOMMON" },
}
