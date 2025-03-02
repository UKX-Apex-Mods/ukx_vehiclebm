FiveM Script: Gang Vehicle Theft and Black Market Sales


Overview

This FiveM script introduces a dynamic and immersive gameplay mechanic where gang-affiliated players can steal NPC vehicles and sell them to the black market. The system is designed to add depth to roleplay scenarios, encourage strategic planning, and create high-stakes interactions with law enforcement.

Key Features
    ● Gang-Exclusive Access: Only players who are part of a gang can utilize the vehicle theft and black market system.
    ● Command-Based Interaction: Players must use the /stealvehicle command after entering an NPC vehicle to initiate the theft process.
    ● Police Notification: Activating the /stealvehicle command alerts law enforcement, adding tension and risk to the operation.
    ● Timer Mechanic: A cooldown timer starts after the command is used, requiring players to wait before selling the vehicle.
    ● Black Market Economy:
        ○ Vehicles are sold to the black market for 50% of their original price.
        ○ The black market resells vehicles at 75% of their original price.
        ○ Not all vehicles are eligible for black market transactions, ensuring balance and realism.




Installation
1. Download and Extract:
    ● Download the script files and extract them into your server's resources folder.
    ● Ensure the folder is named [ukx_vehiclebm] (or your preferred name).
2. Add to server.cfg:
    ● Open your server.cfg file and add the following line:
        ensure [ukx_vehiclebm]
3. Database Setup :
    ● Open the script folder for [ukx_vehiclebm] (or the folder where the script resides).
    ● Locate the gang.sql file included in the script. This file contains the SQL commands required to create the database tables and populate any initial data.
    ● Open the file and follow the steps prompted to you.
4. Dependencies:
    ● Ensure the following resources are installed and running:
        ○ OxMySQL (for database integration).
        ○ qb-menu (this will create the menu for the black market store).




Usage:
For Gang Members:
    1. Stealing a Vehicle:
        ● Enter an NPC vehicle.
        ● Use the /stealvehicle command to initiate the theft process.
        ● A notification will be sent to the police, and a timer will start.
    2. Selling the Vehicle:
        ● Once the timer expires, drive the vehicle to the black market location.
        ● Interact with the black market NPC or terminal to sell the vehicle.
        ● Receive 50% of the vehicle's original price as payment.
For Police:
    ● Receive a notification when a vehicle theft is initiated.
    ● Use the notification details to track and intercept the suspect.




Configuration and Instructions:
    This section provides a detailed guide on how players can interact with the vehicle theft and black market system, using the config.lua setup as the foundation. Below are the customizable elements and gameplay mechanics, clearly explained to ensure players understand their options and restrictions.
    ● Menu Interactions
        ○ Menu Type:
            - Config.MenuType = "qb-menu".
            - Currently, the menu system uses "qb-Menu" for interaction.
            - Future integration for customnui will be available as an alternative menu system.
    ● Black Market Locations
        ○ Sell Vehicles:
            - Config.BlackMarketSellLocation = vector3(100.0, -2000.0, 20.0). 
            - Players can bring eligible vehicles here to sell them for 50% of their original price.
    ● Menu Access:
            - Config.BlackMarketMenuLocation = vector3(108.73, -1988.42, 20.53).
            - Use this menu to interact with the black market.
    ● Radius of Activity
        ○ Radius for Selling the Vehicle
            - Config.BlackMarketRadius = 10.0 
            - Players must be within a 10-meter radius of the Black Market location to initiate any transactions.


Vehicle Pricing and Limits
    ● Sell Price Multiplier:
        ○ Config.SellPriceMultiplier = 0.5.
        ○ Stolen vehicles can be sold at 50% of their original price. This is calculated automatically by the system based on the vehicle's base value.
    ● Weekly Sales Limit:
        ○ Config.WeeklyVehicleLimit = 7.
        ○ Each gang has a limit of 7 vehicles that they can sell to the black market per week. This ensures balance and prevents overuse of the system.
    ● Cooldown Timer:
        ○ Config.CooldownTime = 600  -- 10 minutes.
        ○ After selling a vehicle, a 10-minute cooldown applies to the entire gang. During this time, no other vehicles can be sold by the gang.
    ● Wait Time Before Selling:
        ○ Config.WaitTimeBeforeSell = 30 -- 30 seconds.
        ○ After initiating a vehicle theft with /stealvehicle, players must wait for 30 seconds before they can sell the vehicle to the black market. This creates an element of tension and opportunity for police intervention.


Test Drive and Purchase Features
    ● Test Drive:
        ○ Test Drive Location:
            - Config.TestDriveLocation = vector3(100.0, -2000.0, 20.0).
        ○ Test Drive Duration:
            - Players can take a vehicle for a 30-second test drive before purchasing it from the black market.
    ● Vehicle Spawn After Purchase:
        ○ Vehicle Spawn Location:
            - Config.BuyVehicleSpawnLocation = vector3(100.0, -2000.0, 20.0)    
            - Purchased vehicles will spawn ready for immediate use.


Gang Restrictions
       ●  Permited Gangs
            - Config.AllowedGangs = {
                  "ballas",
                  "vagos",
                  "cartel",
              }
            - Only players belonging to the specified gangs can access the vehicle theft and black market system.




Development Notes

Script Workflow:
    1. Gang Verification:
        ● The script checks if the player belongs to an allowed gang before enabling the /stealvehicle command.
    2. Police Notification:
        ● When the command is used, a notification is sent to all online police officers.
    3. Cooldown Timer:
        ● A timer prevents immediate sale of the vehicle, adding a layer of risk and strategy.
    4. Black Market Interaction:
        ● Players can only sell eligible vehicles at the black market after the timer expires.
Vehicle Eligibility:
    ● Certain restricted vehicles (e.g., emergency vehicles, military vehicles) cannot be sold at the black market.
    ● The script includes a predefined list of eligible vehicles, which can be modified in vehiclelist.lua.



Known Issues:
    ● The custom nui is still in progress, it will freeze the screen if used.  Stop the script by pressing "F8" and typing "stop ukx_vehiclebm" in the console to regaing control of your screen.
    ● The script is currently designed for use with the "qb-menu" resource. Future updates will include support for customnui and other menu systems.


Future Enhancements:
    ● Dynamic Black Market Locations:
        ○ Add multiple black market locations that rotate periodically for added challenge.
    ● Police GPS Integration:
        ○ Provide police with a GPS marker for the stolen vehicle's location.


Credits
Developer: oOUnKnownXOo/UKX Apex Mods

Contributors: PSSRod420, Krispy1017