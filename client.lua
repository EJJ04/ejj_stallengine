local engineStalledVehicles = {} 
local lastVehicleHealth = 0

RegisterNetEvent("carEngineStalling:checkStalling")
AddEventHandler("carEngineStalling:checkStalling", function(vehicle)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        local currentHealth = GetVehicleBodyHealth(vehicle)
        local healthDifference = lastVehicleHealth - currentHealth

        if healthDifference > Config.MinHealthDifference and not engineStalledVehicles[vehicle] then
            TriggerEvent("carEngineStalling:stallEngineAndDizzy", vehicle)
            engineStalledVehicles[vehicle] = true
        end

        lastVehicleHealth = currentHealth
    end
end)

RegisterNetEvent("carEngineStalling:stallEngineAndDizzy")
AddEventHandler("carEngineStalling:stallEngineAndDizzy", function(vehicle)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        if not engineStalledVehicles[vehicle] then
            engineStalledVehicles[vehicle] = true
            SetVehicleEngineOn(vehicle, false, true, true)
            
            lib.notify({
                description = Config.StallingNotification,
                type = 'inform'
            })

            Citizen.CreateThread(function()
                while engineStalledVehicles[vehicle] do
                    Citizen.Wait(0)
                    DisableControlAction(0, 63, true)
                    DisableControlAction(0, 64, true)
                    DisableControlAction(0, 71, true)
                    DisableControlAction(0, 72, true)
                end
            end)

            Citizen.Wait(Config.StallingDuration)

            lib.notify({
                description = Config.RestartNotification,
                type = 'inform'
            })

            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                SetVehicleEngineOn(vehicle, true, true, false)
                engineStalledVehicles[vehicle] = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if cache.ped and IsPedInAnyVehicle(cache.ped, false) then
            local vehicle = GetVehiclePedIsIn(cache.ped, false)

            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local currentHealth = GetVehicleBodyHealth(vehicle)
                local healthDifference = lastVehicleHealth - currentHealth
                
                local speed = (Config.Unit == 'kph') and (GetEntitySpeed(vehicle) * 3.6) or (GetEntitySpeed(vehicle) * 2.236936)
                
                if healthDifference > Config.MinHealthDifference and speed > Config.Speed and not engineStalledVehicles[vehicle] then
                    TriggerEvent("carEngineStalling:checkStalling", vehicle)
                end

                lastVehicleHealth = currentHealth
            end
        end
    end
end)