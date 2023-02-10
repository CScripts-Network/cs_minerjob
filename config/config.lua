Config = {}

Config.Lang = 'en'
Config.FrameWork = 'QBCORE' -- Only supports ESX and QBCORE
Config.Jobs = false -- Put false for no job lock
Config.FixCarSpawnQB = false -- Set this to true if car is not spawning
Config.SpawnBack = true -- Spawns player next to the ped when gives back the car

--- Vehicle ---
Config.UsingFuel = false
Config.JobCar = 'biff'

--- TARGET ---
Config.TargetName = 'qtarget'
Config.StartJobEmote = 'fa-solid fa-handshake-simple'
Config.ClothesJobEmote = 'fa-solid fa-shirt'

--- JOB SETTINGS ---
Config.TurnOffGameShake = false
Config.Job = {
    StartJob = { -- Ped Location
        Coords = vector4(2569.47, 2720.32, 42.95-0.99, 208.84),
        Ped = 's_m_m_dockwork_01',
        blip = {
            SetBlipSprite = 354,
            SetBlipDisplay = 4,
            SetBlipScale = 0.8,
            SetBlipColour = 5,
            SetBlipAsShortRange = true,
        }
    },
    CarControl = { --Spawn/Detete Car
        Coords = vector3(2575.83, 2715.06, 42.52-0.89),
        heading = 293.77,
        DrawDistance = 4.0
    },
    BlipOfMinerSite = { --Spawn/Detete Car
        Coords = vector3(2950.13, 2780.3, 39.73),
        SetBlipSprite = 354,
        SetBlipDisplay = 4,
        SetBlipScale = 0.8,
        SetBlipColour = 5,
        SetBlipAsShortRange = true,
    }
}

Config.Clothes = {
    male = {
        components = {{["component_id"] = 0, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 1, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 3, ["texture"] = 0, ["drawable"] = 30},{["component_id"] = 4, ["texture"] = 0, ["drawable"] = 36},{["component_id"] = 5, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 6, ["texture"] = 1, ["drawable"] = 56},{["component_id"] = 7, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 8, ["texture"] = 1, ["drawable"] = 59},{["component_id"] = 9, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 10, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 11, ["texture"] = 0, ["drawable"] = 56},},
    },
    female = {
        components = {{["component_id"] = 0, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 1, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 3, ["texture"] = 0, ["drawable"] = 57},{["component_id"] = 4, ["texture"] = 0, ["drawable"] = 35},{["component_id"] = 5, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 6, ["texture"] = 1, ["drawable"] = 59},{["component_id"] = 7, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 8, ["texture"] = 1, ["drawable"] = 36},{["component_id"] = 9, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 10, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 11, ["texture"] = 1, ["drawable"] = 49},},
    }
}

Config.JobWork = {
    [1] = {
        PayForOneRock = '1',
        Blip = {
            SetBlipSprite = 354,
            SetBlipDisplay = 4,
            SetBlipScale = 0.8,
            SetBlipColour = 5,
            SetBlipAsShortRange = true,
        },
        BigRocks = {
            [1] = vector3(2945.1, 2765.65, 39.95),
            [2] = vector3(2936.83, 2778.13, 39.2),
            [3] = vector3(2928.22, 2800.24, 41.36),
            [4] = vector3(2932.8, 2812.36, 43.51),
        },
        SmallRocks = {
            [1] = vector3(2953.61, 2818.11, 42.37),
            [2] = vector3(2969.85, 2805.06, 42.36),
            [3] = vector3(2969.08, 2795.73, 40.82),
        },
    },
}

--- FUNCTIONS ---
function GetFrameWork()
    return Config.FrameWork
end

local QBCore = nil
local ESX = nil
if GetFrameWork() == 'ESX' then
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    end)
elseif GetFrameWork() == 'QBCORE' then
    QBCore = exports['qb-core']:GetCoreObject()
end
function SetCarFuel(callback_vehicle)
    if Config.UsingFuel then
        exports['LegacyFuel']:SetFuel(callback_vehicle, '100')
    end
end
function Notify(message)
    if GetFrameWork() == 'ESX' then
        ESX.ShowNotification(message, false, false, w)
    elseif GetFrameWork() == 'QBCORE' then
        QBCore.Functions.Notify(message, "primary")
    end
end