local QBCore = exports['qb-core']:GetCoreObject()

local sellLocation = Config.BlackMarketSellLocation
local menuLocation = Config.BlackMarketMenuLocation
local blackMarketRadius = Config.BlackMarketRadius
local playerSellTimers = {}
local isInSellZone = false
local isInMenuZone = false
local isPlayerInGangCache = nil
local testDriveVehicle = nil
local testDriveTimer = nil

local function isPlayerInGang(callback)
    if isPlayerInGangCache ~= nil then
        callback(isPlayerInGangCache)
    else
        QBCore.Functions.TriggerCallback('blackmarket:checkGang', function(isInGang)
            isPlayerInGangCache = isInGang
            callback(isInGang)
        end)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)

        isInSellZone = #(playerCoords - sellLocation) <= blackMarketRadius
        isInMenuZone = #(playerCoords - menuLocation) <= blackMarketRadius

        if not isInSellZone and not isInMenuZone then
            isPlayerInGangCache = nil
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isInSellZone then
            DrawText3D(sellLocation.x, sellLocation.y, sellLocation.z + 1.0, '[E] Sell Stolen Vehicle')

            isPlayerInGang(function(isInGang)
                if isInGang and IsControlJustPressed(1, 51) then
                    local player = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(player, false)
                    if vehicle ~= 0 then
                        local vehicleProps = GetVehicleProperties(vehicle)
                        TriggerServerEvent('blackmarket:sellVehicle', vehicleProps)
                    else
                        TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'You are not in a vehicle!' } })
                    end
                end
            end)
        end

        if isInMenuZone then
            DrawText3D(menuLocation.x, menuLocation.y, menuLocation.z + 1.0, '[G] Open Vehicle Menu')

            isPlayerInGang(function(isInGang)
                if isInGang and IsControlJustPressed(1, 47) then
                    if Config.MenuType == "qb-menu" then
                        DisplayVehiclePurchaseMenu()
                    else
                        SetNuiFocus(true, true)
                        SendNUIMessage({ action = 'openMenu' })
                    end
                end
            end)
        end

        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            if GetVehicleEngineHealth(testDriveVehicle) <= 0 then
                DeleteVehicle(testDriveVehicle)
                testDriveVehicle = nil
                testDriveTimer = nil
                TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'Test drive vehicle has been totaled!' } })
                SetEntityCoords(PlayerPedId(), menuLocation.x, menuLocation.y, menuLocation.z, false, false, false, true)
            end
        end

        if testDriveTimer and GetGameTimer() > testDriveTimer then
            if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
                DeleteVehicle(testDriveVehicle)
            end
            testDriveVehicle = nil
            testDriveTimer = nil
            TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'Test drive time is over!' } })
            SetEntityCoords(PlayerPedId(), menuLocation.x, menuLocation.y, menuLocation.z, false, false, false, true)
        end
    end
end)

RegisterCommand('stealvehicle', function()
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    if vehicle ~= 0 then
        local vehicleProps = GetVehicleProperties(vehicle)
        local playerCoords = GetEntityCoords(player)
        local streetHash, crossingHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
        local streetName = GetStreetNameFromHashKey(streetHash)
        if not streetName or streetName == "" then
            streetName = "an unknown location"
        end
        vehicleProps.street = streetName
        TriggerServerEvent('blackmarket:vehicleStolen', vehicleProps)
        playerSellTimers[player] = GetGameTimer() + Config.WaitTimeBeforeSell * 1000
    else
        TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'You are not in a vehicle!' } })
    end
end)

RegisterNetEvent('blackmarket:notInGang')
AddEventHandler('blackmarket:notInGang', function()
    TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'You must be part of a gang to sell vehicles!' } })
end)

RegisterNetEvent('blackmarket:vehicleNotAllowed')
AddEventHandler('blackmarket:vehicleNotAllowed', function()
    TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'This vehicle cannot be sold here!' } })
end)

RegisterNetEvent('blackmarket:vehicleSold')
AddEventHandler('blackmarket:vehicleSold', function(sellPrice)
    TriggerEvent('chat:addMessage', { args = { '^2Black Market', 'Vehicle sold for $' .. sellPrice } })
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)
    if vehicle ~= 0 then
        DeleteVehicle(vehicle)
    end
end)

RegisterNetEvent('blackmarket:vehicleReportedStolen')
AddEventHandler('blackmarket:vehicleReportedStolen', function(name, brand)
    TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'This vehicle has now been reported stolen!' } })
    TriggerEvent('chat:addMessage', { args = { '^2Black Market', name .. ' ' .. brand } })
end)

RegisterNetEvent('blackmarket:initiateTestDrive')
AddEventHandler('blackmarket:initiateTestDrive', function(vehicleModel, testDriveLocation, testDriveTime)
    local player = PlayerPedId()
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Citizen.Wait(0)
    end
    testDriveVehicle = CreateVehicle(vehicleModel, testDriveLocation.x, testDriveLocation.y, testDriveLocation.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(player, testDriveVehicle, -1)
    testDriveTimer = GetGameTimer() + testDriveTime * 1000
    SetTimeout(testDriveTime * 1000, function()
        if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
            DeleteVehicle(testDriveVehicle)
            testDriveVehicle = nil
            testDriveTimer = nil
            TriggerEvent('chat:addMessage', { args = { '^1Black Market', 'Test drive time is over!' } })
            SetEntityCoords(PlayerPedId(), menuLocation.x, menuLocation.y, menuLocation.z, false, false, false, true)
        end
    end)
end)

RegisterNetEvent('blackmarket:spawnPurchasedVehicle')
AddEventHandler('blackmarket:spawnPurchasedVehicle', function(vehicleProps, spawnLocation)
    RequestModel(vehicleProps.model)
    while not HasModelLoaded(vehicleProps.model) do
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(vehicleProps.model, spawnLocation.x, spawnLocation.y, spawnLocation.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

    local playerPed = PlayerPedId()
    local playerName = QBCore.Functions.GetPlayerData().charinfo.firstname .. " " .. QBCore.Functions.GetPlayerData().charinfo.lastname
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerServerEvent('gift:addVehicleToGarage',     
        QBCore.Functions.GetPlayerData().license,
        QBCore.Functions.GetPlayerData().citizenid,
        vehicleProps.model,
        GetEntityModel(vehicle),
        "{}",
        plate,
        'pillboxgarage',
        1,
        playerName
    )
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local scale = 0.35
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

function GetVehicleProperties(vehicle)
    local props = {
        model = GetEntityModel(vehicle),
        modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower(),
        plate = GetVehicleNumberPlateText(vehicle),
        color = GetVehicleColor(vehicle),
        name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
        brand = GetLabelText(GetMakeNameFromVehicleModel(GetEntityModel(vehicle)))
    }
    return props
end

function DisplayVehiclePurchaseMenu()
    QBCore.Functions.TriggerCallback('blackmarket:getAvailableVehicles', function(vehicles)
        local brands = {}
        for _, vehicle in pairs(vehicles) do
            brands[vehicle.vehicle_brand] = true
        end
        local brandMenu = {}
        for brand, _ in pairs(brands) do
            table.insert(brandMenu, { header = brand, params = { event = 'blackmarket:selectBrand', args = brand } })
        end
        table.insert(brandMenu, { header = "< Back", params = { event = 'blackmarket:mainMenu' } })
        exports['qb-menu']:openMenu(brandMenu)
    end)
end

RegisterNetEvent('blackmarket:selectBrand')
AddEventHandler('blackmarket:selectBrand', function(selectedBrand)
    QBCore.Functions.TriggerCallback('blackmarket:getAvailableVehicles', function(vehicles)
        local vehicleMenu = {}
        for _, vehicle in pairs(vehicles) do
            if vehicle.vehicle_brand == selectedBrand then
                table.insert(vehicleMenu, { header = vehicle.vehicle_name .. ' ($' .. math.floor(vehicle.vehicle_price * 0.75) .. ')', params = { event = 'blackmarket:selectVehicle', args = vehicle } })
            end
        end
        table.insert(vehicleMenu, { header = "< Back", params = { event = 'blackmarket:mainMenu' } })
        exports['qb-menu']:openMenu(vehicleMenu)
    end)
end)

RegisterNetEvent('blackmarket:selectVehicle')
AddEventHandler('blackmarket:selectVehicle', function(selectedVehicle)
    local actionMenu = {
        { header = 'Test Drive', params = { event = 'blackmarket:testDriveVehicle', args = selectedVehicle.vehicle_model } },
        { header = 'Buy Now', params = { event = 'blackmarket:buyVehicle', args = { model = selectedVehicle.vehicle_model, price = math.floor(selectedVehicle.vehicle_price * 0.75) } } },
        { header = "< Back", params = { event = 'blackmarket:selectBrand', args = selectedVehicle.vehicle_brand } }
    }
    exports['qb-menu']:openMenu(actionMenu)
end)

RegisterNetEvent('blackmarket:testDriveVehicle')
AddEventHandler('blackmarket:testDriveVehicle', function(vehicleModel)
    TriggerServerEvent('blackmarket:testDriveVehicle', vehicleModel, Config.TestDriveLocation, Config.TestDriveTime)
end)

RegisterNetEvent('blackmarket:buyVehicle')
AddEventHandler('blackmarket:buyVehicle', function(data)
    TriggerServerEvent('blackmarket:buyVehicle', data.model, data.price)
end)

RegisterNetEvent('blackmarket:mainMenu')
AddEventHandler('blackmarket:mainMenu', function()
    DisplayVehiclePurchaseMenu()
end)

-- NUI Callbacks
RegisterNUICallback('closeMenu', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('buyVehicle', function(data)
    TriggerServerEvent('blackmarket:buyVehicle', data.model, data.price)
end)

RegisterNUICallback('testDriveVehicle', function(data)
    TriggerServerEvent('blackmarket:testDriveVehicle', data.model, Config.TestDriveLocation, Config.TestDriveTime)
end)

RegisterNUICallback('selectVehicle', function(data)
    SendNUIMessage({
        action = 'showInfo',
        brand = data.brand,
        name = data.name,
        type = data.type,
        price = data.price,
        stats = data.stats
    })
end)

RegisterNUICallback('goBack', function(data)
    SendNUIMessage({
        action = 'backToCategory'
    })
end)