-- config.lua

Config = {}

Config.MenuType = "customnui"  -- Options: "qb-menu", will use qb-menu to create the menu, or "customnui", will use custom NUI to create the menu.
-- custom NUI in progress

-- Location settings
Config.BlackMarketSellLocation = vector3(100.0, -2000.0, 20.0)      -- Location for selling vehicles
Config.BlackMarketMenuLocation = vector3(108.73, -1988.42, 20.53)   -- Location for opening the menu
Config.BlackMarketRadius = 10.0                                     -- Radius around the black market where players can sell vehicles

-- Pricing settings
Config.SellPriceMultiplier = 0.5                                    -- Multiplier for the vehicle's original price to determine the sell price
Config.WeeklyVehicleLimit = 7                                       -- Weekly limit of vehicles each gang can sell
Config.CooldownTime = 600                                           -- Cooldown time before selling another vehicle in seconds (for the gang)
Config.WaitTimeBeforeSell = 30                                     -- Time a player must wait before selling a stolen vehicle in seconds

Config.TestDriveLocation = vector3(100.0, -2000.0, 20.0)            -- Location of the test drive
Config.TestDriveTime = 30                                           -- Test drive time in seconds
Config.BuyVehicleSpawnLocation = vector3(100.0, -2000.0, 20.0)      -- Location of the vehicle spawn after purchase

-- Gangs allowed to sell vehicles
Config.AllowedGangs = {
    "ballas",
    "vagos",
    "cartel",
}