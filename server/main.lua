local RESOURCE_NAME = GetCurrentResourceName()
local DATA_FILE = 'data/applications.json'
local applications = {}
local QBCore = nil

local function getQBCore()
    if QBCore then return QBCore end
    if GetResourceState('qb-core') == 'started' then
        local ok, obj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok then QBCore = obj end
    end
    return QBCore
end

local function ensureDataFile()
    local raw = LoadResourceFile(RESOURCE_NAME, DATA_FILE)
    if raw and raw ~= '' then
        local decoded = json.decode(raw)
        if type(decoded) == 'table' then
            applications = decoded
            return
        end
    end
    applications = {}
    SaveResourceFile(RESOURCE_NAME, DATA_FILE, json.encode(applications, { indent = true }), -1)
end

local function persistApplications()
    SaveResourceFile(RESOURCE_NAME, DATA_FILE, json.encode(applications, { indent = true }), -1)
end

local function sanitizeInput(text)
    if not text then return '' end
    text = tostring(text):gsub('```', ''):gsub('[*_~|`]', '')
    if #text > 3000 then text = text:sub(1, 3000) end
    return text
end

local function getPlayerIdentifiersMap(src)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier then
            identifiers[identifier:match('^(.-):') or identifier] = identifier:match(':(.+)$') or identifier
        end
    end
    return identifiers
end

local function getFullIdentifierList(src)
    local list = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        list[#list + 1] = GetPlayerIdentifier(src, i)
    end
    return list
end

local function nowIso()
    return os.date('!%Y-%m-%dT%H:%M:%SZ')
end

local function getCharacterFullName(player)
    if not player or not player.PlayerData or not player.PlayerData.charinfo then return nil end
    local c = player.PlayerData.charinfo
    local first, last = c.firstname or '', c.lastname or ''
    local full = (first .. ' ' .. last):gsub('^%s+', ''):gsub('%s+$', '')
    return full ~= '' and full or nil
end

local function notify(src, msgType, description)
    if GetResourceState('ox_lib') == 'started' then
        TriggerClientEvent('ox_lib:notify', src, { type = msgType or 'inform', description = description })
    else
        TriggerClientEvent('chat:addMessage', src, { args = { '^3Applications', description } })
    end
end

local function validateInput(input)
    if not input then return false, 'No input provided' end
    if not input.fullName or #input.fullName < 2 or #input.fullName > 60 then return false, 'Invalid full name' end
    if not input.age or tonumber(input.age) == nil then return false, 'Invalid age' end
    local age = tonumber(input.age)
    if age < 16 or age > 90 then return false, 'Age must be between 16 and 90' end
    if not input.dateOfBirth or #input.dateOfBirth < 8 then return false, 'Invalid date of birth' end
    if not input.phone or #input.phone < 3 or #input.phone > 30 then return false, 'Invalid phone number' end
    if not input.discord or #input.discord < 2 or #input.discord > 32 then return false, 'Invalid Discord username' end
    if not input.discordId or not tostring(input.discordId):match('^%d+$') then return false, 'Invalid Discord ID' end
    if not input.experience or #input.experience < 1 then return false, 'Select your experience level' end
    if not input.motivation or #input.motivation < 50 or #input.motivation > 700 then return false, 'Motivation must be between 50 and 700 characters' end
    if not input.availability or #input.availability < 1 then return false, 'Select your availability' end
    if input.references and #input.references > 500 then return false, 'References must be less than 500 characters' end
    return true, 'Valid'
end

local function buildHistoryEntry(action, src, note)
    local entry = {
        at = nowIso(),
        action = action,
        by = GetPlayerName(src) or 'System',
        src = src,
    }
    if note and note ~= '' then entry.note = sanitizeInput(note) end
    return entry
end

local function hasManagementAccess(src, businessKey)
    if not Config.Management.enabled then return false end

    if Config.Management.acePermission and IsPlayerAceAllowed(src, Config.Management.acePermission) then
        return true
    end

    local fullIdentifiers = getFullIdentifierList(src)
    for _, allowed in ipairs(Config.Management.identifiers or {}) do
        for _, playerIdentifier in ipairs(fullIdentifiers) do
            if allowed == playerIdentifier then
                return true
            end
        end
    end

    local qb = getQBCore()
    if qb then
        local player = qb.Functions.GetPlayer(src)
        if player and player.PlayerData and player.PlayerData.job then
            local jobName = string.lower(player.PlayerData.job.name or '')
            if businessKey and Config.Businesses[businessKey] and string.lower(Config.Businesses[businessKey].businessType or '') == jobName then
                if not Config.Management.requireBoss then return true end
                return player.PlayerData.job.isboss == true or ((player.PlayerData.job.grade and player.PlayerData.job.grade.level) or 0) >= 3
            end
            if Config.Management.jobs[jobName] then
                if not Config.Management.requireBoss then return true end
                return player.PlayerData.job.isboss == true or ((player.PlayerData.job.grade and player.PlayerData.job.grade.level) or 0) >= 3
            end
        end
    end

    return false
end

local function getApplicantKey(application)
    return application and application.applicant and application.applicant.license or 'unknown'
end

local function getApplicationsForBusiness(businessKey)
    if not businessKey or businessKey == '' then return applications end
    local filtered = {}
    for _, application in ipairs(applications) do
        if application.businessKey == businessKey then
            filtered[#filtered + 1] = application
        end
    end
    table.sort(filtered, function(a, b) return (a.createdAt or '') > (b.createdAt or '') end)
    return filtered
end

local function getApplicantApplicationsByLicense(license, businessKey)
    local filtered = {}
    for _, application in ipairs(applications) do
        if application.applicant and application.applicant.license == license and (not businessKey or businessKey == '' or application.businessKey == businessKey) then
            filtered[#filtered + 1] = application
        end
    end
    table.sort(filtered, function(a, b) return (a.createdAt or '') > (b.createdAt or '') end)
    return filtered
end

local function getApplicantApplicationsForSource(src, businessKey)
    local identifiers = getPlayerIdentifiersMap(src)
    if not identifiers.license then return {} end
    return getApplicantApplicationsByLicense(identifiers.license, businessKey)
end

local function getOnlineSourcesByLicense(license)
    local matches = {}
    for _, playerId in ipairs(GetPlayers()) do
        local ids = getPlayerIdentifiersMap(tonumber(playerId))
        if ids.license == license then matches[#matches + 1] = tonumber(playerId) end
    end
    return matches
end

local function sendApplicantLiveNotification(application, text)
    if not Config.Notifications.enableLiveNotify then return end
    local license = getApplicantKey(application)
    for _, src in ipairs(getOnlineSourcesByLicense(license)) do
        notify(src, 'inform', text)
    end
end

local function sendDiscordNotification(business, application, updateType)
    if not business.webhook or business.webhook == '' then return end
    local title = business.businessName .. ' Application'
    local color = 3447003
    if updateType == 'status' then
        title = business.businessName .. ' Application Updated'
        color = application.status == 'accepted' and 5763719 or application.status == 'denied' and 15548997 or application.status == 'interview' and 16776960 or 3447003
    end

    local latestHistory = application.history and application.history[#application.history]
    local fields = {
        { name = 'Applicant', value = application.applicant.fullName .. ' (' .. application.applicant.serverName .. ')', inline = true },
        { name = 'Job', value = application.jobTitle, inline = true },
        { name = 'Status', value = application.status, inline = true },
        { name = 'Phone', value = application.applicant.phone, inline = true },
        { name = 'Discord', value = application.applicant.discord .. ' / ' .. application.applicant.discordId, inline = true },
        { name = 'Availability', value = application.applicant.availability, inline = true },
        { name = 'Motivation', value = application.applicant.motivation:sub(1, 1024), inline = false },
    }
    if application.management and application.management.interviewAt ~= '' then
        fields[#fields + 1] = { name = 'Interview', value = application.management.interviewAt, inline = true }
    end
    if application.management and application.management.applicantNotes ~= '' then
        fields[#fields + 1] = { name = 'Applicant Update', value = application.management.applicantNotes:sub(1, 1024), inline = false }
    end
    if latestHistory and latestHistory.note then
        fields[#fields + 1] = { name = 'Latest Action', value = (latestHistory.action or 'updated') .. ' â€” ' .. latestHistory.note:sub(1, 1024), inline = false }
    end

    PerformHttpRequest(business.webhook, function() end, 'POST', json.encode({
        username = 'Tech Applications',
        embeds = {{
            title = title,
            color = color,
            fields = fields,
            footer = { text = 'tech_application upgraded by ChatGPT' },
            timestamp = nowIso()
        }}
    }), { ['Content-Type'] = 'application/json' })
end

local function buildApplicationRecord(src, input, businessKey)
    local identifiers = getPlayerIdentifiersMap(src)
    local qb = getQBCore()
    local qbPlayer = qb and qb.Functions.GetPlayer(src) or nil
    local business = Config.Businesses[businessKey]
    local fullName = sanitizeInput(input.fullName)
    if fullName == '' then
        fullName = getCharacterFullName(qbPlayer) or (GetPlayerName(src) or 'Unknown Player')
    end

    local previous = getApplicantApplicationsByLicense(identifiers.license or 'unknown', businessKey)

    return {
        id = ('app_%s_%s'):format(os.time(), math.random(1000, 9999)),
        businessKey = businessKey,
        businessType = business.businessType,
        businessName = business.businessName,
        jobTitle = business.jobTitle,
        status = 'pending',
        unreadApplicantUpdates = 0,
        theme = business.theme or {},
        applicant = {
            serverName = GetPlayerName(src) or 'Unknown Player',
            fullName = fullName,
            age = tonumber(input.age),
            dateOfBirth = sanitizeInput(input.dateOfBirth),
            phone = sanitizeInput(input.phone),
            gender = sanitizeInput(input.gender),
            discord = sanitizeInput(input.discord),
            discordId = sanitizeInput(input.discordId),
            experience = sanitizeInput(input.experience),
            availability = sanitizeInput(input.availability),
            motivation = sanitizeInput(input.motivation),
            references = sanitizeInput(input.references or ''),
            license = identifiers.license or 'unknown',
            fivem = identifiers.fivem or 'unknown',
            citizenid = qbPlayer and qbPlayer.PlayerData and qbPlayer.PlayerData.citizenid or 'unknown',
        },
        management = {
            interviewAt = '',
            interviewLocation = '',
            interviewInstructions = '',
            interviewNotes = '',
            applicantNotes = '',
            managerNotes = '',
            updatedBy = '',
            updatedAt = nowIso(),
        },
        history = {
            buildHistoryEntry('submitted', src, ('Application submitted. Previous applications for this business: %s'):format(#previous))
        },
        previousCount = #previous,
        createdAt = nowIso(),
    }
end

lib.callback.register('tech_application:getApplications', function(source, businessKey)
    if not hasManagementAccess(source, businessKey) then
        return { success = false, message = 'You do not have access to manage applications.' }
    end
    return { success = true, applications = getApplicationsForBusiness(businessKey) }
end)

lib.callback.register('tech_application:getApplicantApplications', function(source, businessKey)
    local apps = getApplicantApplicationsForSource(source, businessKey)
    return { success = true, applications = apps }
end)

lib.callback.register('tech_application:updateApplicationStatus', function(source, data)
    if not data or not data.id then
        return { success = false, message = 'Invalid update request.' }
    end

    local application
    for _, entry in ipairs(applications) do
        if entry.id == data.id then application = entry break end
    end
    if not application then
        return { success = false, message = 'Application not found.' }
    end
    if not hasManagementAccess(source, application.businessKey) then
        return { success = false, message = 'You do not have access to update this application.' }
    end

    application.status = sanitizeInput(data.status or application.status)
    application.management.interviewAt = sanitizeInput(data.interviewAt or '')
    application.management.interviewLocation = sanitizeInput(data.interviewLocation or '')
    application.management.interviewInstructions = sanitizeInput(data.interviewInstructions or '')
    application.management.interviewNotes = sanitizeInput(data.interviewNotes or '')
    application.management.applicantNotes = sanitizeInput(data.applicantNotes or '')
    application.management.managerNotes = sanitizeInput(data.managerNotes or '')
    application.management.updatedBy = GetPlayerName(source) or 'Unknown'
    application.management.updatedAt = nowIso()
    application.unreadApplicantUpdates = (application.unreadApplicantUpdates or 0) + 1

    application.history = application.history or {}
    local historyNote = ('Status: %s'):format(application.status)
    if application.management.interviewAt ~= '' then
        historyNote = historyNote .. (' | Interview: %s'):format(application.management.interviewAt)
    end
    if application.management.applicantNotes ~= '' then
        historyNote = historyNote .. (' | Update: %s'):format(application.management.applicantNotes)
    end
    application.history[#application.history + 1] = buildHistoryEntry('updated', source, historyNote)

    persistApplications()

    local business = Config.Businesses[application.businessKey]
    sendDiscordNotification(business, application, 'status')

    local updateText = (application.status == 'interview' and Config.Notifications.interviewUpdateText or Config.Notifications.applicantUpdateText):format(application.businessName, application.status)
    sendApplicantLiveNotification(application, updateText)

    return { success = true, application = application, message = 'Application updated successfully.' }
end)

lib.callback.register('tech_application:markApplicantUpdatesRead', function(source, data)
    local targetId = data and data.id
    if not targetId then return { success = false } end
    local ids = getPlayerIdentifiersMap(source)
    for _, application in ipairs(applications) do
        if application.id == targetId and application.applicant.license == ids.license then
            application.unreadApplicantUpdates = 0
            application.history = application.history or {}
            application.history[#application.history + 1] = buildHistoryEntry('viewed', source, 'Applicant reviewed latest updates.')
            persistApplications()
            return { success = true, application = application }
        end
    end
    return { success = false, message = 'Application not found.' }
end)

RegisterServerEvent('tech_application:requestManagementOpen', function(businessKey)
    local src = source
    if not hasManagementAccess(src, businessKey) then
        notify(src, 'error', 'You do not have access to the management panel.')
        return
    end

    if not businessKey or businessKey == '' then
        local qb = getQBCore()
        if qb then
            local player = qb.Functions.GetPlayer(src)
            if player and player.PlayerData and player.PlayerData.job then
                local jobName = string.lower(player.PlayerData.job.name or '')
                for key, business in pairs(Config.Businesses) do
                    if string.lower(business.businessType or '') == jobName then businessKey = key break end
                end
            end
        end
    end

    local businessName = businessKey and Config.Businesses[businessKey] and Config.Businesses[businessKey].businessName or 'All Applications'
    TriggerClientEvent('tech_application:openManagement', src, {
        businessKey = businessKey,
        businessName = businessName,
        applications = getApplicationsForBusiness(businessKey)
    })
end)

RegisterServerEvent('tech_application:sendApply', function(input, businessKey)
    local src = source
    if not businessKey or not Config.Businesses[businessKey] then
        notify(src, 'error', 'Invalid business selected.')
        return
    end

    local isValid, errorMsg = validateInput(input)
    if not isValid then
        notify(src, 'error', errorMsg)
        return
    end

    local application = buildApplicationRecord(src, input, businessKey)
    applications[#applications + 1] = application
    persistApplications()
    sendDiscordNotification(Config.Businesses[businessKey], application, 'new')

    notify(src, 'success', 'Application submitted successfully. You can return here anytime to track updates.')
end)

CreateThread(function()
    ensureDataFile()
end)
