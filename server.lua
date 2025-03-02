local QBCore = exports['qb-core']:GetCoreObject()
local stolenVehicles = {}
local gangCooldowns = {}
local playerSellTimers = {}

local function initializeDatabase()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS bmgangsold (
            id INT AUTO_INCREMENT PRIMARY KEY,
            gang VARCHAR(50),
            player_id INT,
            name VARCHAR(100),
            vehicle VARCHAR(50),
            amount INT,
            sale_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    ]], {}, function()
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS bmganglimit (
                gang VARCHAR(50) PRIMARY KEY,
                weekly_limit INT
            );
        ]], {}, function()
            MySQL.Async.execute([[
                CREATE TABLE IF NOT EXISTS bmvehiclelist (
                    vehicle_name VARCHAR(100),
                    vehicle_model VARCHAR(50),
                    vehicle_brand VARCHAR(50),
                    vehicle_type VARCHAR(50),
                    vehicle_price INT
                );
            ]], {})
        end)
    end)
end

local function isVehicleStolen(vehicle)
    for _, stolenVehicle in ipairs(stolenVehicles) do
        if stolenVehicle.plate == vehicle.plate then
            return true
        end
    end
    return false
end

local function isVehicleAllowed(vehicle)
    for _, allowedVehicle in ipairs(VehicleList) do
        print('Checking vehicle model: ' .. vehicle.modelName .. ' against allowed model: ' .. allowedVehicle.model)
        if allowedVehicle.model == vehicle.modelName then
            return allowedVehicle.price
        end
    end
    return nil
end

local function getCurrentWeek()
    local currentDate = os.date('*t')
    local weekStart = os.time{year=currentDate.year, month=currentDate.month, day=currentDate.day - currentDate.wday + 1}
    local weekEnd = os.time{year=currentDate.year, month=currentDate.month, day=currentDate.day - currentDate.wday + 7, hour=23, min=59, sec=59}
    return weekStart, weekEnd
end

local function hasGangReachedLimit(gang, callback)
    local weekStart, weekEnd = getCurrentWeek()
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM bmgangsold WHERE gang = @gang AND sale_timestamp BETWEEN @weekStart AND @weekEnd', {
        ['@gang'] = gang,
        ['@weekStart'] = os.date('%Y-%m-%d %H:%M:%S', weekStart),
        ['@weekEnd'] = os.date('%Y-%m-%d %H:%M:%S', weekEnd)
    }, function(count)
        callback(count >= Config.WeeklyVehicleLimit)
    end)
end

local function sellStolenVehicle(player, vehicle)
    if isVehicleStolen(vehicle) then
        local originalPrice = isVehicleAllowed(vehicle)
        if originalPrice then
            local sellPrice = originalPrice * Config.SellPriceMultiplier
            local xPlayer = QBCore.Functions.GetPlayer(player)
            local playerGang = xPlayer.PlayerData.gang.name
            local playerName = xPlayer.PlayerData.charinfo.firstname .. ' ' .. xPlayer.PlayerData.charinfo.lastname

            hasGangReachedLimit(playerGang, function(hasReachedLimit)
                if hasReachedLimit then
                    TriggerClientEvent('chat:addMessage', player, { args = { '^1Black Market', 'Your gang has reached the weekly vehicle sale limit!' } })
                else
                    gangCooldowns[playerGang] = os.time() + Config.CooldownTime

                    xPlayer.Functions.AddMoney('cash', sellPrice)
                    for i, stolenVehicle in ipairs(stolenVehicles) do
                        if stolenVehicle.plate == vehicle.plate then
                            table.remove(stolenVehicles, i)
                            break
                        end
                    end
                    MySQL.Async.execute('INSERT INTO bmgangsold (gang, player_id, name, vehicle, amount) VALUES (@gang, @player_id, @name, @vehicle, @amount)', {
                        ['@gang'] = playerGang,
                        ['@player_id'] = xPlayer.PlayerData.citizenid,
                        ['@name'] = playerName,
                        ['@vehicle'] = vehicle.modelName,
                        ['@amount'] = sellPrice
                    })
                    MySQL.Async.execute('INSERT INTO bmvehiclelist (vehicle_name, vehicle_model, vehicle_brand, vehicle_type, vehicle_price) VALUES (@vehicle_name, @vehicle_model, @vehicle_brand, @vehicle_type, @vehicle_price)', {
                        ['@vehicle_name'] = vehicle.name,
                        ['@vehicle_model'] = vehicle.modelName,
                        ['@vehicle_brand'] = vehicle.brand,
                        ['@vehicle_type'] = vehicle.type,
                        ['@vehicle_price'] = originalPrice
                    })
                    TriggerClientEvent('blackmarket:vehicleSold', player, sellPrice)
                end
            end)
        else
            TriggerClientEvent('blackmarket:vehicleNotAllowed', player)
        end
    else
        TriggerClientEvent('chat:addMessage', player, { args = { '^1Black Market', 'This vehicle is not stolen!' } })
    end
end

RegisterServerEvent('blackmarket:sellVehicle')
AddEventHandler('blackmarket:sellVehicle', function(vehicle)
    local player = source
    local xPlayer = QBCore.Functions.GetPlayer(player)
    local playerGang = xPlayer.PlayerData.gang.name

    if isPlayerInGang(player) then
        if gangCooldowns[playerGang] and gangCooldowns[playerGang] > os.time() then
            local remainingTime = gangCooldowns[playerGang] - os.time()
            TriggerClientEvent('chat:addMessage', player, { args = { '^1Black Market', 'Your gang needs to wait ' .. remainingTime .. ' seconds before selling another vehicle!' } })
        else
            if playerSellTimers[player] and playerSellTimers[player] > os.time() then
                local remainingTime = playerSellTimers[player] - os.time()
                TriggerClientEvent('chat:addMessage', player, { args = { '^1Black Market', 'You need to wait ' .. remainingTime .. ' seconds before selling this vehicle!' } })
            else
                sellStolenVehicle(player, vehicle)
            end
        end
    else
        TriggerClientEvent('blackmarket:notInGang', player)
    end
end)

RegisterServerEvent('blackmarket:vehicleStolen')
AddEventHandler('blackmarket:vehicleStolen', function(vehicle)
    local player = source
    table.insert(stolenVehicles, vehicle)
    playerSellTimers[player] = os.time() + Config.WaitTimeBeforeSell

    TriggerClientEvent('blackmarket:vehicleReportedStolen', player, vehicle.name, vehicle.brand)

    local message = string.format("A vehicle has been stolen!\nA %s %s %s has been stolen near %s. The stolen vehicle license plate is %s.\nPlease be advised suspect might be armed, approach with caution.",
        vehicle.color, vehicle.name, vehicle.brand, vehicle.street, vehicle.plate)
    TriggerClientEvent('police:notify', -1, message)
end)

function AddMoneyToPlayer(player, amount)
    local xPlayer = QBCore.Functions.GetPlayer(player)
    if xPlayer then
        xPlayer.Functions.AddMoney('cash', amount)
    end
end

function isPlayerInGang(player)
    local playerGang = GetPlayerGang(player)
    print("Player's Gang: " .. tostring(playerGang))
    for _, gang in ipairs(Config.AllowedGangs) do
        if playerGang and playerGang.name == gang then
            print("Player is in a gang: " .. gang)
            return true
        end
    end
    print("Player is not in an allowed gang")
    return false
end

function GetPlayerGang(player)
    local xPlayer = QBCore.Functions.GetPlayer(player)
    if xPlayer then
        return xPlayer.PlayerData.gang
    end
    return nil
end

QBCore.Functions.CreateCallback('blackmarket:checkGang', function(source, cb)
    local isInGang = isPlayerInGang(source)
    cb(isInGang)
end)

RegisterServerEvent('blackmarket:testDriveVehicle')
AddEventHandler('blackmarket:testDriveVehicle', function(vehicleModel)
    local player = source
    local xPlayer = QBCore.Functions.GetPlayer(player)
    if xPlayer then
        TriggerClientEvent('blackmarket:initiateTestDrive', player, vehicleModel, Config.TestDriveLocation, Config.TestDriveTime)
    end
end)

RegisterServerEvent('blackmarket:buyVehicle')
AddEventHandler('blackmarket:buyVehicle', function(vehicleModel, vehiclePrice)
    local player = source
    local xPlayer = QBCore.Functions.GetPlayer(player)
    if xPlayer then
        if xPlayer.Functions.RemoveMoney('cash', vehiclePrice) then
            local vehicleProps = { model = vehicleModel }
            TriggerClientEvent('blackmarket:spawnPurchasedVehicle', player, vehicleProps, Config.BuyVehicleSpawnLocation)
            MySQL.Async.execute('DELETE FROM bmvehiclelist WHERE vehicle_model = @vehicle_model', {
                ['@vehicle_model'] = vehicleModel
            })
        else
            TriggerClientEvent('chat:addMessage', player, { args = { '^1Black Market', 'You do not have enough money to buy this vehicle!' } })
        end
    end
end)

QBCore.Functions.CreateCallback('blackmarket:getAvailableVehicles', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM bmvehiclelist', {}, function(vehicles)
        cb(vehicles)
    end)
end)

QBCore.Functions.CreateCallback('blackmarket:getAvailableVehicles', function(source, cb)
    local result = MySQL.Sync.fetchAll('SELECT * FROM bmvehiclelist ORDER BY vehicle_type, vehicle_name')
    cb(result)
end)

RegisterServerEvent('blackmarket:buyVehicle')
AddEventHandler('blackmarket:buyVehicle', function(vehicleModel, price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', price) then
        TriggerClientEvent('blackmarket:spawnPurchasedVehicle', src, vehicleModel, Config.BuyVehicleSpawnLocation)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Not enough money', 'error')
    end
end)

RegisterServerEvent('blackmarket:testDriveVehicle')
AddEventHandler('blackmarket:testDriveVehicle', function(vehicleModel, testDriveLocation, testDriveTime)
    local src = source
    TriggerClientEvent('blackmarket:initiateTestDrive', src, vehicleModel, testDriveLocation, testDriveTime)
end)

QBCore.Functions.CreateCallback('blackmarket:getVehiclesByCategory', function(source, cb, category)
    local result = MySQL.Sync.fetchAll('SELECT * FROM bmvehiclelist WHERE vehicle_type = @category ORDER BY vehicle_name', { ['@category'] = category })
    cb(result)
end)

initializeDatabase()