
local IsInGuild = IsInGuild
local IsInInstance = IsInInstance
local SendAddonMessage = SendAddonMessage
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local CreateFrame = CreateFrame

local myname = UnitName("player")
versionRB = GetAddOnMetadata("RaidBrowser", "Version")

local spamt = 0
local timeneedtospam = 180
do
    local SendMessageWaitingRB
    local SendRecieveGroupSizeRB = 0
    function SendMessage_RB()
        if GetNumRaidMembers() > 1 then
            local _, instanceType = IsInInstance()
            if instanceType == "pvp" then
                SendAddonMessage("RBVC", versionRB, "BATTLEGROUND")
            else
                SendAddonMessage("RBVC", versionRB, "RAID")
            end
        elseif GetNumPartyMembers() > 0 then
            SendAddonMessage("RBVC", versionRB, "PARTY")
        elseif IsInGuild() then
            SendAddonMessage("RBVC", versionRB, "GUILD")
        end
        SendMessageWaitingRB = nil
    end

    local function SendRecieve_RB(_, event, prefix, message, _, sender)
        if event == "CHAT_MSG_ADDON" then
            -- print(argtime)
            if prefix ~= "RBVC" then return end
            if not sender or sender == myname then return end

            local ver = tonumber(versionRB)
            message = tonumber(message)

            local  timenow = time()
            if message and (message > ver) then
                if timenow - spamt >= timeneedtospam then
                    print("|cff1784d1".."RaidBrowser".."|r".." (".."|cffff0000"..ver.."|r"..") устарел. Вы можете загрузить последнюю версию (".."|cff00ff00"..message.."|r"..") из ".."|cffffcc00".."https://github.com/fxpw/RaidBrowser-ru-for-sirus".."|r")
                    -- spamt = time()
                    spamt = time()
                end
            end
        end

        if event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
            local numRaid = GetNumRaidMembers()
            local num = numRaid > 0 and numRaid or (GetNumPartyMembers() + 1)
            if num ~= SendRecieveGroupSizeRB then
                if num > 1 and num > SendRecieveGroupSizeRB then
                    if not SendMessageWaitingRB then
                        SendMessage_RB()
                        -- SendMessageWaitingBB = E:Delay(10,SendMessage_BB )
                    end
                end
                SendRecieveGroupSizeRB = num
            end
        elseif event == "PLAYER_ENTERING_WORLD" then
                    if not SendMessageWaitingRB then
                        SendMessage_RB()
                        -- SendMessageWaitingBB = E:Delay(10, SendMessage_BB)
                    end

            end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_ADDON")
    f:RegisterEvent("RAID_ROSTER_UPDATE")
    f:RegisterEvent("PARTY_MEMBERS_CHANGED")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", SendRecieve_RB)
end