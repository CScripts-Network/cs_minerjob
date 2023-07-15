local Core = exports['cs_lib']:GetLib()

RegisterNetEvent('d_minerjob:givemoney')
AddEventHandler('d_minerjob:givemoney', function(JobsToDo, SetRandomLocation)
    Core.GiveMoney(source, 'cash', JobsToDo*Config.JobWork[SetRandomLocation].PayForOnePoint)
end)