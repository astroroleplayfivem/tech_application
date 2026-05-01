local spawnedPeds = {}
local spawnedZones = {}

local function getZoneName(businessKey, locationIndex, locationName, suffix)
    return ("techapp_%s_%s_%s_%s"):format(businessKey, locationIndex, locationName, suffix or 'main')
end

local function addTargetZone(zoneName, location, callback, label, icon)
    if Config.Target == 'OX' then
        exports.ox_target:addBoxZone({
            name = zoneName,
            coords = vec3(location.coords.x, location.coords.y, location.coords.z),
            size = vec3(1.2, 1.2, 3.5),
            rotation = location.coords.w or 0.0,
            options = {{ name = zoneName, onSelect = callback, icon = icon or 'fa-solid fa-file-signature', label = label }}
        })
    else
        exports['qb-target']:AddBoxZone(zoneName, vector3(location.coords.x, location.coords.y, location.coords.z - 1.0), 1.2, 1.2, {
            name = zoneName,
            heading = location.coords.w,
            debugPoly = false,
            minZ = location.coords.z - 1.0,
            maxZ = location.coords.z + 1.25,
        }, {
            options = {{ name = zoneName, action = callback, icon = icon or 'fa-solid fa-file-signature', label = label }},
            distance = 2.3
        })
    end
    spawnedZones[#spawnedZones + 1] = zoneName
end

local function addPedTargets(ped, businessKey, business, locationIndex, location)
    local options = {
        {
            icon = business.theme and business.theme.icon or 'fa-solid fa-file-signature',
            label = location.label,
            action = function()
                TriggerEvent('tech_application:openPortal', businessKey)
            end,
            onSelect = function()
                TriggerEvent('tech_application:openPortal', businessKey)
            end,
        }
    }

    if Config.Management.enabled and Config.Management.allowTargetAccess then
        options[#options + 1] = {
            icon = 'fa-solid fa-clipboard-check',
            label = Config.Management.managementLabel,
            action = function()
                TriggerServerEvent('tech_application:requestManagementOpen', businessKey)
            end,
            onSelect = function()
                TriggerServerEvent('tech_application:requestManagementOpen', businessKey)
            end,
        }
    end

    if Config.Target == 'OX' then
        local payload = {}
        for idx, option in ipairs(options) do
            payload[#payload + 1] = {
                name = getZoneName(businessKey, locationIndex, location.name, ('ped_%s'):format(idx)),
                icon = option.icon,
                label = option.label,
                onSelect = option.onSelect,
            }
        end
        exports.ox_target:addLocalEntity(ped, payload)
    else
        local payload = { options = {}, distance = 2.3 }
        for _, option in ipairs(options) do
            payload.options[#payload.options + 1] = {
                icon = option.icon,
                label = option.label,
                action = option.action,
            }
        end
        exports['qb-target']:AddTargetEntity(ped, payload)
    end
end

CreateThread(function()
    for businessKey, business in pairs(Config.Businesses) do
        for locationIndex, location in ipairs(business.locations) do
            local applyZoneName = getZoneName(businessKey, locationIndex, location.name, 'apply')
            addTargetZone(applyZoneName, location, function()
                TriggerEvent('tech_application:openPortal', businessKey)
            end, location.label, business.theme and business.theme.icon or 'fa-solid fa-file-signature')

            if Config.Management.enabled and Config.Management.allowTargetAccess then
                local managementZoneName = getZoneName(businessKey, locationIndex, location.name, 'manage')
                addTargetZone(managementZoneName, location, function()
                    TriggerServerEvent('tech_application:requestManagementOpen', businessKey)
                end, Config.Management.managementLabel, 'fa-solid fa-clipboard-check')
            end

            if location.ped then
                local modelHash = joaat(location.pedModel)
                RequestModel(modelHash)
                local timeout = GetGameTimer() + 5000
                while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do Wait(25) end
                if HasModelLoaded(modelHash) then
                    local ped = CreatePed(4, modelHash, location.coords.x, location.coords.y, location.coords.z - 1.0, location.coords.w, false, true)
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    spawnedPeds[#spawnedPeds + 1] = ped
                    addPedTargets(ped, businessKey, business, locationIndex, location)
                    SetModelAsNoLongerNeeded(modelHash)
                else
                    print(("^1[tech_application] Failed to load ped model %s for %s^7"):format(location.pedModel, businessKey))
                end
            end
        end
    end
end)

RegisterNetEvent('tech_application:openPortal', function(businessKey)
    local business = Config.Businesses[businessKey]
    if not business then return end
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openPortal',
        businessKey = businessKey,
        businessName = business.businessName,
        jobTitle = business.jobTitle,
        theme = business.theme or {},
    })
end)

RegisterNetEvent('tech_application:openManagement', function(payload)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'openManagement',
        businessKey = payload.businessKey,
        businessName = payload.businessName,
        applications = payload.applications or {}
    })
end)

RegisterNUICallback('submitApplication', function(data, cb)
    TriggerServerEvent('tech_application:sendApply', data.data, data.businessKey)
    cb({ success = true })
end)

RegisterNUICallback('cancelPortal', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'closePortal' })
    cb('ok')
end)

RegisterNUICallback('fetchApplicantApplications', function(data, cb)
    local response = lib.callback.await('tech_application:getApplicantApplications', false, data.businessKey)
    cb(response or { success = false, message = 'Failed to load applications.' })
end)

RegisterNUICallback('markApplicantUpdatesRead', function(data, cb)
    local response = lib.callback.await('tech_application:markApplicantUpdatesRead', false, data)
    cb(response or { success = false, message = 'Failed to mark updates as read.' })
end)

RegisterNUICallback('fetchManagementApplications', function(data, cb)
    local response = lib.callback.await('tech_application:getApplications', false, data.businessKey)
    cb(response or { success = false, message = 'Failed to load applications.' })
end)

RegisterNUICallback('updateApplicationStatus', function(data, cb)
    local response = lib.callback.await('tech_application:updateApplicationStatus', false, data)
    cb(response or { success = false, message = 'Failed to update application.' })
end)

RegisterNUICallback('closeManagement', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'closeManagement' })
    cb('ok')
end)

RegisterCommand(Config.Management.command, function()
    TriggerServerEvent('tech_application:requestManagementOpen')
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, zoneName in ipairs(spawnedZones) do
        if Config.Target == 'OX' then
            pcall(function() exports.ox_target:removeZone(zoneName) end)
        else
            pcall(function() exports['qb-target']:RemoveZone(zoneName) end)
        end
    end
end)
  
