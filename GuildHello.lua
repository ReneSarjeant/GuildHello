local greetingDelay = 5
local rosterRefreshInterval = 5
local onlineMembers
local pendingGreetings = {}
local rosterTicker

local function RequestRoster()
    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    else
        GuildRoster()
    end
end

local function ReadOnlineMembers()
    local members = {}
    local total = GetNumGuildMembers()
    if total == 0 then
        return
    end

    for index = 1, total do
        local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(index)
        if not name then
            return
        end
        if online then
            members[name] = true
        end
    end
    return members
end

local function ScheduleGreeting(name)
    pendingGreetings[name] = C_Timer.NewTimer(greetingDelay, function()
        pendingGreetings[name] = nil
        local currentMembers = IsInGuild() and ReadOnlineMembers()
        if currentMembers and currentMembers[name] then
            local shortName = Ambiguate(name, "short")
            local send = C_ChatInfo and C_ChatInfo.SendChatMessage or SendChatMessage
            send("[René] Hi, " .. shortName .. "!", "GUILD")
        end
    end)
end

local function UpdateRoster()
    local currentMembers = ReadOnlineMembers()
    if not currentMembers then
        return
    end

    if onlineMembers then
        for name, timer in pairs(pendingGreetings) do
            if not currentMembers[name] then
                timer:Cancel()
                pendingGreetings[name] = nil
            end
        end

        for name in pairs(currentMembers) do
            if not onlineMembers[name] then
                ScheduleGreeting(name)
            end
        end
    end
    onlineMembers = currentMembers
end

local function RefreshMembership()
    if IsInGuild() then
        if not rosterTicker then
            rosterTicker = C_Timer.NewTicker(rosterRefreshInterval, RequestRoster)
        end
        RequestRoster()
        return
    end

    if rosterTicker then
        rosterTicker:Cancel()
        rosterTicker = nil
    end
    for _, timer in pairs(pendingGreetings) do
        timer:Cancel()
    end
    pendingGreetings = {}
    onlineMembers = nil
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_GUILD_UPDATE")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")
frame:SetScript("OnEvent", function(_, event)
    if event == "GUILD_ROSTER_UPDATE" then
        if IsInGuild() then
            UpdateRoster()
        end
    else
        RefreshMembership()
    end
end)
