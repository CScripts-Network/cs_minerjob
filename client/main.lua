local HasJobStarted = false
local HasJob = true
local SetRandomLocation
local CarParked = false
local POINTS_DONE_IN_JOB = 0
local HaveJob = false
local JobsToDo
local NumberToDo = 0
local geeky
local PropsBlips = {}
local ClothesOn = false
local blip
local QBCore = nil
local ESX = nil
local blipSY
local Player
local isSpawned = false
local SendedInfo = false
local Zone = CircleZone:Create(vector2(2944.70, 2775.38), 77.19, {
    name="miner",
})   

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

Citizen.CreateThread(function()
	SpawnStartingPed()
    local Blip_Name = Config.Languages[Config.Lang]["MAIN_BLIP"]
    blip = AddBlipForCoord(Config.Job.StartJob.Coords.x, Config.Job.StartJob.Coords.y, Config.Job.StartJob.Coords.z)
    SetBlipSprite(blip, Config.Job.StartJob.blip.SetBlipSprite)
    SetBlipDisplay(blip, Config.Job.StartJob.blip.SetBlipDisplay)
    SetBlipScale(blip, Config.Job.StartJob.blip.SetBlipScale)
    SetBlipColour(blip, Config.Job.StartJob.blip.SetBlipColour )
    SetBlipAsShortRange(blip, Config.Job.StartJob.blip.SetBlipAsShortRange )
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Blip_Name)
    EndTextCommandSetBlipName(blip)
end)

--MAIN CODE--

CreateThread(function()
	while true do
		Citizen.Wait(1000)
        if not Config.Jobs then
            HasJob = true
        elseif GetFrameWork() == "ESX" and ESX.GetPlayerData().job.name == Config.Jobs then
            HasJob = true
        elseif GetFrameWork() == "QBCORE" and QBCore.Functions.GetPlayerData().job.name == Config.Jobs then
            HasJob = true
        else
            HasJob = false
        end
    end
end)

CreateThread(function()
	while true do
        sleep = 1000
        if HasJob and HasJobStarted then
            sleep = 0
            -- JOB UPDATES --
            JobsToDo = #Config.JobWork[SetRandomLocation].BigRocks + #Config.JobWork[SetRandomLocation].SmallRocks
            NumberToDo = JobsToDo-POINTS_DONE_IN_JOB

            if POINTS_DONE_IN_JOB == JobsToDo and not SendedInfo then
                Notify(Config.Languages[Config.Lang]["JOB_DONE_COME_BACK"])
                SetNewWaypoint(Config.Job.StartJob.Coords.x, Config.Job.StartJob.Coords.y)
                SendedInfo = true
            end

            -- END OF JOB UPDATES --

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - Config.Job.CarControl.Coords)
            if distance < Config.Job.CarControl.DrawDistance+1 and IsPedInAnyVehicle(PlayerPedId()) then
                if distance < Config.Job.CarControl.DrawDistance-2 then
                    DrawMarker(23, Config.Job.CarControl.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.5, 3.5, 3.0, 136, 8, 8, 100, false, true, 2, false, nil, nil, false)
                    DrawText3Ds(Config.Job.CarControl.Coords, Config.Languages[Config.Lang]["CAR_BACK"])
                    if IsControlJustReleased(0,46) then
                        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                        DeleteVehicle(vehicle)
                        SetNewWaypoint(Config.Job.BlipOfMinerSite.Coords.x, Config.Job.BlipOfMinerSite.Coords.y);
                        DeleteWaypoint();
                        if NumberToDo == 0 then
                            Notify(Config.Languages[Config.Lang]["YOU_EARNED"]..''..tonumber(JobsToDo)*tonumber(Config.JobWork[SetRandomLocation].PayForOneRock))
                            TriggerServerEvent("d_gardencleaner:givemoney", JobsToDo, SetRandomLocation)
                        end
                        HasJobStarted = false
                        SetRandomLocation = nil
                        CarParked = false
                        POINTS_DONE_IN_JOB = 0
                        HaveJob = false
                        JobsToDo = 0
                        NumberToDo = 0
                        geeky = nil
                        SendedInfo = false
                        isSpawned = false
                        if Config.SpawnBack then
                            SetEntityCoords(GetPlayerPed(-1), Config.Job.StartJob.Coords.x, Config.Job.StartJob.Coords.y, Config.Job.StartJob.Coords.z, false, false, false, true)
                        end
                    end
                else
                    DrawMarker(23, Config.Job.CarControl.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.5, 3.5, 3.0, 255, 255, 255, 100, false, true, 2, false, nil, nil, false)
                end
            else
                sleep = 1500
            end
        end
        Citizen.Wait(sleep)
	end
end)

CreateThread(function()
	while true do
        sleep = 1000
        if HasJob and HasJobStarted then
            sleep = 0
            local plyPed = PlayerPedId()
            local coord = GetEntityCoords(plyPed)
            insidePinkCage = Zone:isPointInside(coord)
                if insidePinkCage and not isSpawned then
                        Notify(Config.Languages[Config.Lang]["HOW_TO_START"])
                        CarParked = true
                        SpawnSmallRocks()
                        SpawnBigRocks()
                        RemoveBlip(blipSY)
                        isSpawned = true
                end
        end
        Citizen.Wait(sleep)
	end
end)

RegisterNetEvent('d_minerjob:startjob')
AddEventHandler('d_minerjob:startjob', function()
        if HasJobStarted and not CarParked then
            HasJobStarted = false
            SetRandomLocation = nil
            CarParked = false
            POINTS_DONE_IN_JOB = 0
            HaveJob = false
            JobsToDo = 0
            NumberToDo = 0
            geeky = nil
            RemoveBlip(blipSY)
            SendedInfo = false
            isSpawned = false
        elseif not HasJobStarted then
            HasJobStarted = true
            local RandomLocal = math.random(1,#Config.JobWork)
            SpawnCar()
            SetNewWaypoint(Config.Job.BlipOfMinerSite.Coords.x, Config.Job.BlipOfMinerSite.Coords.y);
            SetRandomLocation = RandomLocal
            Notify('Go to the mining zone!')
            local Blip_Name = 'Mining Zone'
            blipSY = AddBlipForCoord(Config.Job.BlipOfMinerSite.Coords.x, Config.Job.BlipOfMinerSite.Coords.y, Config.Job.BlipOfMinerSite.Coords.z)
            SetBlipSprite(blipSY, Config.Job.BlipOfMinerSite.SetBlipSprite)
            SetBlipDisplay(blipSY, Config.Job.BlipOfMinerSite.SetBlipDisplay)
            SetBlipScale(blipSY, Config.Job.BlipOfMinerSite.SetBlipScale)
            SetBlipColour(blipSY, Config.Job.BlipOfMinerSite.SetBlipColour )
            SetBlipAsShortRange(blipSY, Config.Job.BlipOfMinerSite.SetBlipAsShortRange )
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Blip_Name)
            EndTextCommandSetBlipName(blipSY)
        else
            Notify(Config.Languages[Config.Lang]["DONT_START_AGAIN"])
        end
end)

function Animation()
    Citizen.CreateThread(function()
        while impacts < 5 do
            Citizen.Wait(1)
                RequestAnimDict("melee@large_wpn@streamed_core")
                Citizen.Wait(100)
                TaskPlayAnim((ped), 'melee@large_wpn@streamed_core', 'ground_attack_on_spot', 8.0, 8.0, -1, 80, 0, 0, 0, 0)
                if impacts == 0 then
                    pickaxe = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true) 
                    AttachEntityToEntity(pickaxe, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)
                end  
                Citizen.Wait(2500)
                ClearPedTasks(ped)
                impacts = impacts+1
                if impacts == 5 then
                    DetachEntity(pickaxe, 1, true)
                    DeleteEntity(pickaxe)
                    DeleteObject(pickaxe)
                    mineActive = false
                    impacts = 0
                    break
                end        
        end
    end)
end

function MinerAnimation(data) 
    if not HasNamedPtfxAssetLoaded("core") then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(10)
        end
    end
    
    if not HasAnimDictLoaded("melee@hatchet@streamed_core") then
        RequestAnimDict("melee@hatchet@streamed_core")
    end
    while not HasAnimDictLoaded("melee@hatchet@streamed_core") do
        Citizen.Wait(0)
    end

    local rockPos = GetEntityCoords(data.entity)
    local plyCoords = GetEntityCoords(PlayerPedId())
    TaskPlayAnim(PlayerPedId(), 'melee@hatchet@streamed_core', 'plyr_rear_takedown_b', 8.0, -8.0, -1, 2, 0, false, false, false)
    --local timer = GetGameTimer() + 800
    --while GetGameTimer() <= timer do Wait(0) DisableControlAction(0, 24, true) end
    if Config.TurnOffGameShake then
        ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.3)
    end
    --ClearPedTasks(PlayerPedId())
    --SetEntityCoords(data.entity, rockPos.x, rockPos.y, rockPos.z - 0.2)
    UseParticleFxAssetNextCall("core")
    SetParticleFxNonLoopedColour(1.0, 0.0, 0.0) 
    StartNetworkedParticleFxNonLoopedAtCoord("ent_col_rocks", plyCoords.x + 0.5, plyCoords.y, plyCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false) 
    RemoveNamedPtfxAsset("core") 
    local entity = GetEntityCoords(data.entity);
    SetEntityCoords(data.entity, entity.x, entity.y, entity.z-0.30, false, false, false, false);
end

RegisterNetEvent('d_minerjob:smallrock')
AddEventHandler('d_minerjob:smallrock', function(data)
    HaveJob = true
    ClearPedTasks(GetPlayerPed(-1))
    local model = loadModel(GetHashKey('prop_tool_pickaxe'))
    geeky = CreateObject(model, GetEntityCoords(GetPlayerPed(-1)), false, false, false)
    AttachEntityToEntity(geeky, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)
    FreezeEntityPosition(GetPlayerPed(-1), true)
    MinerAnimation(data)
    Citizen.Wait(1000)
    MinerAnimation(data)
    Citizen.Wait(1000)
    MinerAnimation(data)
    Citizen.Wait(1000)
    MinerAnimation(data)
    Citizen.Wait(1500)
    FreezeEntityPosition(GetPlayerPed(-1), false)
    DeleteObject(geeky)
    DeleteEntity(data.entity)
    ClearPedTasks(GetPlayerPed(-1))
    POINTS_DONE_IN_JOB = POINTS_DONE_IN_JOB+1
    Notify(Config.Languages[Config.Lang]["DONE"]..""..POINTS_DONE_IN_JOB.."/"..JobsToDo)
    RemoveBlip(PropsBlips[data.entity])
    HaveJob = false
end)

RegisterNetEvent('d_minerjob:bigrock')
AddEventHandler('d_minerjob:bigrock', function(data)
    HaveJob = true
    ClearPedTasks(GetPlayerPed(-1))
    local model = loadModel(GetHashKey('prop_tool_pickaxe'))
    geeky = CreateObject(model, GetEntityCoords(GetPlayerPed(-1)), false, false, false)
    AttachEntityToEntity(geeky, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.09, 0.03, -0.02, -78.0, 13.0, 28.0, false, true, true, true, 0, true)
    FreezeEntityPosition(GetPlayerPed(-1), true)
    MinerAnimation(data)
    Citizen.Wait(1000)
    MinerAnimation(data)
    Citizen.Wait(1000)
    MinerAnimation(data)
    Citizen.Wait(1000)
    MinerAnimation(data)
    Citizen.Wait(3000)
    FreezeEntityPosition(GetPlayerPed(-1), false)
    DeleteObject(geeky)
    DeleteEntity(data.entity)
    ClearPedTasks(GetPlayerPed(-1))
    POINTS_DONE_IN_JOB = POINTS_DONE_IN_JOB+1
    Notify(Config.Languages[Config.Lang]["DONE"]..""..POINTS_DONE_IN_JOB.."/"..JobsToDo)
    RemoveBlip(PropsBlips[data.entity])
    HaveJob = false
end)

RegisterNetEvent("mt:missiontext")
AddEventHandler("mt:missiontext", function(text)
        ClearPrints()
        SetTextEntry_2("STRING")
        AddTextComponentString(text)
        DrawSubtitleTimed(5000, 1)
end)

RegisterNetEvent("d_minerjob:putonclothes")
AddEventHandler("d_minerjob:putonclothes", function()
    if ClothesOn then
        ChangeClothes()
    else
        ChangeClothes('work')
    end
end)


--- FUNCTIONS ---
function SpawnStartingPed()
    local model = Config.Job.StartJob.Ped
    RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(50)
	end
    spawnedPed = CreatePed(0, model, Config.Job.StartJob.Coords.x, Config.Job.StartJob.Coords.y, Config.Job.StartJob.Coords.z, Config.Job.StartJob.Coords.w, false, true)
    FreezeEntityPosition(spawnedPed, true)
    SetBlockingOfNonTemporaryEvents(spawnedPed, true)
    SetEntityInvincible(spawnedPed, true)

    if not Config.job then
        exports[Config.TargetName]:AddTargetEntity(spawnedPed, {
            options = {
                {
                    event = "d_minerjob:startjob",
                    icon = Config.StartJobEmote,
                    label = Config.Languages[Config.Lang]["TARGET_START"],
                },
                {
                    event = "d_minerjob:putonclothes",
                    icon = Config.ClothesJobEmote,
                    label = Config.Languages[Config.Lang]["TARGET_CLOTHES"],
                },
            },
            distance = 2.5
        })
    else 
        exports[Config.TargetName]:AddTargetEntity(spawnedPed, {
            options = {
                {
                    event = "d_minerjob:startjob",
                    icon = Config.StartJobEmote,
                    label = Config.Languages[Config.Lang]["TARGET_START"],
                    job = Config.Job
                },
                {
                    event = "d_minerjob:putonclothes",
                    icon = Config.ClothesJobEmote,
                    label = Config.Languages[Config.Lang]["TARGET_CLOTHES"],
                    job = Config.Job
                },
            },
            distance = 2.5
        })
    end
end

function SpawnCar()
    if GetFrameWork() == 'ESX' then
	    ESX.Game.SpawnVehicle(Config.JobCar, Config.Job.CarControl.Coords, Config.Job.CarControl.heading, function(callback_vehicle)
		    SetVehicleFixed(callback_vehicle)
		    SetVehicleDeformationFixed(callback_vehicle)
		    SetVehicleEngineOn(callback_vehicle, true, true)
		    SetCarFuel(callback_vehicle)
		    TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
	    end)
    elseif GetFrameWork() == 'QBCORE' and not Config.FixCarSpawnQB then
        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
            local veh = NetToVeh(netId)
            SetEntityHeading(veh, Config.Job.CarControl.heading)
		    SetVehicleFixed(veh)
		    SetVehicleDeformationFixed(veh)
		    SetVehicleEngineOn(veh, true, true)
		    SetCarFuel(veh)
		    TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        end, Config.JobCar, Config.Job.CarControl.Coords, true)
    elseif GetFrameWork() == 'QBCORE' and Config.FixCarSpawnQB then
        QBCore.Functions.SpawnVehicle(Config.JobCar, function(veh)
            SetEntityHeading(veh, Config.Job.CarControl.heading)
		    SetVehicleFixed(veh)
		    SetVehicleDeformationFixed(veh)
		    SetVehicleEngineOn(veh, true, true)
            SetCarFuel(veh)
            TaskWarpPedIntoVehicle(GetPlayerPed(-1), veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true)
        end, Config.Job.CarControl.Coords, true)    
    end
end

function DrawText3Ds(coords, text)
    local onScreen,_x,_y=World3dToScreen2d(coords.x,coords.y,coords.z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.030+ factor, 0.03, 0, 0, 0, 150)
end

function SpawnSmallRocks()
		local playerPos = GetEntityCoords(GetPlayerPed(-1), true)		
		for i=1, #Config.JobWork[SetRandomLocation].SmallRocks do
        local model = GetHashKey('prop_rock_1_d')
        RequestModel(model)
        while (not HasModelLoaded(model)) do
            Wait(1)
        end
		local p = CreateObject(model, Config.JobWork[SetRandomLocation].SmallRocks[i].x, Config.JobWork[SetRandomLocation].SmallRocks[i].y, Config.JobWork[SetRandomLocation].SmallRocks[i].z-1.30, true, true, true)
        SetModelAsNoLongerNeeded(model)
        SetEntityAsMissionEntity(p, true, true);
        FreezeEntityPosition(p, true)
		SetEntityInvincible(p, true)

        PropsBlips[p] = AddBlipForCoord(Config.JobWork[SetRandomLocation].SmallRocks[i].x, Config.JobWork[SetRandomLocation].SmallRocks[i].y, Config.JobWork[SetRandomLocation].SmallRocks[i].z)
        SetBlipSprite(PropsBlips[p], 1)
        SetBlipDisplay(PropsBlips[p], 4)
        SetBlipScale(PropsBlips[p], 0.4)
        SetBlipColour(PropsBlips[p], 5)
        SetBlipAsShortRange(PropsBlips[p], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Languages[Config.Lang]["BLIP_ROCK"])
        EndTextCommandSetBlipName(PropsBlips[p])

        exports[Config.TargetName]:AddTargetEntity(p, {
            options = {
                {
                    event = "d_minerjob:smallrock",
                    icon = Config.StartJobEmote,
                    label = Config.Languages[Config.Lang]["MINE_THIS"],
                    canInteract = function(entity)
                        if not HaveJob and HasJobStarted then
                            return true
                        end
                        return false
                    end
                },
            },
            distance = 2.5
        })
	end
end
function SpawnBigRocks()
    local playerPos = GetEntityCoords(GetPlayerPed(-1), true)		
    for i=1, #Config.JobWork[SetRandomLocation].BigRocks do
    local model = GetHashKey('csx_coastsmalrock_01_')
    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(1)
    end
    local p = CreateObject(model, Config.JobWork[SetRandomLocation].BigRocks[i].x, Config.JobWork[SetRandomLocation].BigRocks[i].y, Config.JobWork[SetRandomLocation].BigRocks[i].z-0.99, true, true, true)
    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(p, true)
    SetEntityAsMissionEntity(p, true, true);
    SetEntityInvincible(p, true)

    PropsBlips[p] = AddBlipForCoord(Config.JobWork[SetRandomLocation].BigRocks[i].x, Config.JobWork[SetRandomLocation].BigRocks[i].y, Config.JobWork[SetRandomLocation].BigRocks[i].z)
    SetBlipSprite(PropsBlips[p], 1)
    SetBlipDisplay(PropsBlips[p], 4)
    SetBlipScale(PropsBlips[p], 0.4)
    SetBlipColour(PropsBlips[p], 5)
    SetBlipAsShortRange(PropsBlips[p], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Languages[Config.Lang]["BLIP_ROCK"])
    EndTextCommandSetBlipName(PropsBlips[p])

    exports[Config.TargetName]:AddTargetEntity(p, {
        options = {
            {
                event = "d_minerjob:bigrock",
                icon = Config.StartJobEmote,
                label = Config.Languages[Config.Lang]["MINE_THIS"],
                canInteract = function(entity)
                    if not HaveJob and HasJobStarted then
                        return true
                    end
                    return false
                end
            },
        },
        distance = 2.5
    })
    end
end

function ChangeClothes(type) 
    if type == "work" then
        local gender
        if GetFrameWork() == 'ESX' then
        TriggerEvent('skinchanger:getSkin', function(skin)
            gender = skin.sex
        end)
        elseif GetFrameWork() == 'QBCORE' then
            local Player = QBCore.Functions.GetPlayerData()
            gender = Player.charinfo.gender
        end
        local PlayerPed = PlayerPedId()
        ClothesOn = true
        if gender == 0 then
            for k,v in pairs(Config.Clothes.male.components) do
                SetPedComponentVariation(PlayerPed, v["component_id"], v["drawable"], v["texture"], 0)
            end
        else
            for k,v in pairs(Config.Clothes.female.components) do
                SetPedComponentVariation(PlayerPed, v["component_id"], v["drawable"], v["texture"], 0)
            end
        end
    else       
        ClothesOn = false 
        if GetFrameWork() == 'ESX' then
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                TriggerEvent('skinchanger:loadSkin', skin)
            end)
        elseif GetFrameWork() == 'QBCORE' then
            TriggerServerEvent('qb-clothes:loadPlayerSkin')
        end
    end
end

loadModel = function(model)
    while not HasModelLoaded(model) do Wait(0) RequestModel(model) end
    return model
end
