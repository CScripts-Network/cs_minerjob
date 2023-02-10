local QBCore = nil
local ESX = nil

if GetFrameWork() == 'ESX' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif GetFrameWork() == 'QBCORE' then
    QBCore = exports['qb-core']:GetCoreObject()
end

RegisterNetEvent('d_minerjob:givemoney')
AddEventHandler('d_minerjob:givemoney', function(JobsToDo, SetRandomLocation)
    if GetFrameWork() == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addMoney(JobsToDo*Config.JobWork[SetRandomLocation].PayForOnePoint)
    elseif GetFrameWork() == 'QBCORE' then
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.AddMoney("cash", JobsToDo*Config.JobWork[SetRandomLocation].PayForOnePoint)
    end
end)