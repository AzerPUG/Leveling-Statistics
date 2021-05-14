if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end

AZP.VersionControl["Leveling Statistics"] = 11
AZP.LevelingStatistics = {}

local AZPLSSelfOptionsPanel, AZPLSSelfFrame = nil, nil
local EventFrame, UpdateFrame = nil, nil

local xpMax = 0
local xpCur = 0
local xpGained = 0
local xpNeed = 0
local curLevel = 0
local startTime = 0

local optionHeader = "|cFF00FFFFLeveling Statistics|r"

function AZP.LevelingStatistics:OnLoadBoth()
    xpMax = UnitXPMax("player")
    xpCur = UnitXP("player")
    xpNeed = xpGained - xpCur
    curLevel = UnitLevel("player")
    startTime = time()

    AZPLSSelfFrame.text = AZPLSSelfFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    AZPLSSelfFrame.text:SetText("No EXP Gained Yet.")
    AZPLSSelfFrame.text:SetPoint("LEFT", 10, 0)
    AZPLSSelfFrame.text:SetSize(AZPLSSelfFrame:GetWidth(), AZPLSSelfFrame:GetHeight())
    AZPLSSelfFrame.text:SetJustifyH("LEFT")
end

function AZP.LevelingStatistics:OnLoadCore()
    AZPLSSelfFrame = AZP.Core.AddOns.LS.MainFrame
    AZP.Core:RegisterEvents("PLAYER_XP_UPDATE", function(...) AZP.LevelingStatistics:eventPlayerXPUpdate(...) end)

    AZP.LevelingStatistics:OnLoadBoth()

    AZP.OptionsPanels:RemovePanel("Leveling Statistics")
    AZP.OptionsPanels:Generic("Leveling Statistics", optionHeader, function(frame) AZP.LevelingStatistics:FillOptionsPanel(frame) end)
end

function AZP.LevelingStatistics:OnLoadSelf()
    C_ChatInfo.RegisterAddonMessagePrefix("AZPVERSIONS")

    EventFrame = CreateFrame("FRAME", nil)
    EventFrame:RegisterEvent("PLAYER_XP_UPDATE")
    EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    EventFrame:RegisterEvent("CHAT_MSG_ADDON")
    EventFrame:RegisterEvent("VARIABLES_LOADED")
    EventFrame:SetScript("OnEvent", function(...) AZP.LevelingStatistics:OnEvent(...) end)

    UpdateFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    UpdateFrame:SetPoint("CENTER", 0, 250)
    UpdateFrame:SetSize(400, 200)
    UpdateFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    UpdateFrame:SetBackdropColor(0.25, 0.25, 0.25, 0.80)
    UpdateFrame.header = UpdateFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalHuge")
    UpdateFrame.header:SetPoint("TOP", 0, -10)
    UpdateFrame.header:SetText("|cFFFF0000AzerPUG's Leveling Statistics is out of date!|r")

    UpdateFrame.text = UpdateFrame:CreateFontString("UpdateFrame", "ARTWORK", "GameFontNormalLarge")
    UpdateFrame.text:SetPoint("TOP", 0, -40)
    UpdateFrame.text:SetText("Error!")

    UpdateFrame:Hide()

    local UpdateFrameCloseButton = CreateFrame("Button", nil, UpdateFrame, "UIPanelCloseButton")
    UpdateFrameCloseButton:SetWidth(25)
    UpdateFrameCloseButton:SetHeight(25)
    UpdateFrameCloseButton:SetPoint("TOPRIGHT", UpdateFrame, "TOPRIGHT", 2, 2)
    UpdateFrameCloseButton:SetScript("OnClick", function() UpdateFrame:Hide() end )

    AZPLSSelfFrame = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    AZPLSSelfFrame:SetSize(250, 100)
    AZPLSSelfFrame:SetPoint("CENTER", 0, 0)
    AZPLSSelfFrame:SetScript("OnDragStart", AZPLSSelfFrame.StartMoving)
    AZPLSSelfFrame:SetScript("OnDragStop", function()
        AZPLSSelfFrame:StopMovingOrSizing()
        AZP.LevelingStatistics:SaveMainFrameLocation()
    end)
    AZPLSSelfFrame:RegisterForDrag("LeftButton")
    AZPLSSelfFrame:EnableMouse(true)
    AZPLSSelfFrame:SetMovable(true)
    AZPLSSelfFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    AZPLSSelfFrame:SetBackdropColor(0.5, 0.5, 0.5, 0.75)

    local AZPLSSelfFrameCloseButton = CreateFrame("Button", nil, AZPLSSelfFrame, "UIPanelCloseButton")
    AZPLSSelfFrameCloseButton:SetSize(20, 21)
    AZPLSSelfFrameCloseButton:SetPoint("TOPRIGHT", AZPLSSelfFrame, "TOPRIGHT", 2, 2)
    AZPLSSelfFrameCloseButton:SetScript("OnClick", function() AZP.LevelingStatistics:ShowHideFrame() end )

    AZPLSSelfOptionsPanel = CreateFrame("FRAME", nil)
    AZPLSSelfOptionsPanel.name = optionHeader
    InterfaceOptions_AddCategory(AZPLSSelfOptionsPanel)
    AZPLSSelfOptionsPanel.header = AZPLSSelfOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    AZPLSSelfOptionsPanel.header:SetPoint("TOP", 0, -10)
    AZPLSSelfOptionsPanel.header:SetText("|cFF00FFFFAzerPUG's Leveling Statistics Options!|r")

    AZPLSSelfOptionsPanel.footer = AZPLSSelfOptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    AZPLSSelfOptionsPanel.footer:SetPoint("TOP", 0, -300)
    AZPLSSelfOptionsPanel.footer:SetText(
        "|cFF00FFFFAzerPUG Links:\n" ..
        "Website: www.azerpug.com\n" ..
        "Discord: www.azerpug.com/discord\n" ..
        "Twitch: www.twitch.tv/azerpug\n|r"
    )
    AZP.LevelingStatistics:OnLoadBoth()
    AZP.LevelingStatistics:FillOptionsPanel(AZPLSSelfOptionsPanel)
end

function AZP.LevelingStatistics:DelayedExecution(delayTime, delayedFunction)
    local frame = CreateFrame("Frame")
    frame.start_time = GetServerTime()
    frame:SetScript("OnUpdate",
        function(self)
            if GetServerTime() - self.start_time > delayTime then
                delayedFunction()
                self:SetScript("OnUpdate", nil)
                self:Hide()
            end
        end
    )
    frame:Show()
end

function AZP.LevelingStatistics:SaveMainFrameLocation()
    local temp = {}
    temp[1], temp[2], temp[3], temp[4], temp[5] = AZPLSSelfFrame:GetPoint()
    AZPLSLocation = temp
end

function AZP.LevelingStatistics:ShowHideFrame()
    if AZPLSSelfFrame:IsShown() then
        AZPLSSelfFrame:Hide()
        AZPLSShown = false
    elseif not AZPLSSelfFrame:IsShown() then
        AZPLSSelfFrame:Show()
        AZPLSShown = true
    end
end

function AZP.LevelingStatistics:ShareVersion()    -- Change DelayedExecution to native WoW Function.
    local versionString = string.format("|LS:%d|", AZP.VersionControl["Leveling Statistics"])
    AZP.LevelingStatistics:DelayedExecution(10, function()
        if UnitInBattleground("player") ~= nil then
            -- BG stuff?
        else
            if IsInGroup() then
                if IsInRaid() then
                    C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"RAID", 1)
                else
                    C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"PARTY", 1)
                end
            end
            if IsInGuild() then
                C_ChatInfo.SendAddonMessage("AZPVERSIONS", versionString ,"GUILD", 1)
            end
        end
    end)
end

function AZP.LevelingStatistics:ReceiveVersion(version)
    if version > AZP.VersionControl["Leveling Statistics"] then
        if (not HaveShowedUpdateNotification) then
            HaveShowedUpdateNotification = true
            UpdateFrame:Show()
            UpdateFrame.text:SetText(
                "Please download the new version through the CurseForge app.\n" ..
                "Or use the CurseForge website to download it manually!\n\n" ..
                "Newer Version: v" .. version .. "\n" ..
                "Your version: v" .. AZP.VersionControl["Leveling Statistics"]
            )
        end
    end
end

function AZP.LevelingStatistics:GetSpecificAddonVersion(versionString, addonWanted)
    local pattern = "|([A-Z]+):([0-9]+)|"
    local index = 1
    while index < #versionString do
        local _, endPos = string.find(versionString, pattern, index)
        local addon, version = string.match(versionString, pattern, index)
        index = endPos + 1
        if addon == addonWanted then
            return tonumber(version)
        end
    end
end

function AZP.LevelingStatistics:eventPlayerXPUpdate()
    if (curLevel ~= UnitLevel("player")) then
        xpGained = xpGained + (xpMax - xpCur)
        xpMax = UnitXPMax("player")
        curLevel = UnitLevel("player")
        xpGained = xpGained + UnitXP("player")
    else
        xpGained = xpGained + (UnitXP("player") - xpCur)
    end
    xpCur = UnitXP("player")
    xpNeed = xpMax - xpCur

    local timeDifference = time() - startTime

    AZPLSSelfFrame.text:SetText(
        "XP Stats:\n" ..
        "Current: " .. AZP.LevelingStatistics:Round(xpCur / 1000) .. "k / " .. AZP.LevelingStatistics:Round(xpMax / 1000) .. "k. (" .. AZP.LevelingStatistics:Round(xpCur / xpMax * 100) .. "%)\n" ..
        xpGained .. " Total XP Gained.\n" ..
        "XP / Hour: " .. AZP.LevelingStatistics:Round(xpGained / 1000 / (timeDifference / 3600)) .. "k.\n" ..
        AZP.LevelingStatistics:Round(xpNeed / AZP.LevelingStatistics:Round(xpGained / (timeDifference / 60))) .. " min to level " .. (curLevel + 1) .. ".\n" ..
        "Aprox " .. AZP.LevelingStatistics:Round(xpMax / AZP.LevelingStatistics:Round(xpGained / (timeDifference / 60))) .. " minutes / level."
    )
end

function AZP.LevelingStatistics:eventVariablesLoaded(...)
    if AZPLSShown == false then
        AZPLSSelfFrame:Hide()
    end

    if AZPLSLocation == nil then
        AZPLSLocation = {"CENTER", nil, nil, 200, 0}
    end
    AZPLSSelfFrame:SetPoint(AZPLSLocation[1], AZPLSLocation[4], AZPLSLocation[5])
end

function AZP.LevelingStatistics:OnEvent(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, payload, _, sender = ...
        if prefix == "AZPVERSIONS" then
            local version = AZP.LevelingStatistics:GetSpecificAddonVersion(payload, "LS")
            if version ~= nil then
                AZP.LevelingStatistics:ReceiveVersion(version)
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        AZP.LevelingStatistics:ShareVersion()
    elseif event == "PLAYER_XP_UPDATE" then
        AZP.LevelingStatistics:eventPlayerXPUpdate()
    elseif event == "VARIABLES_LOADED" then
        AZP.LevelingStatistics:eventVariablesLoaded(...)
    end
end

function AZP.LevelingStatistics:FillOptionsPanel(frameToFill)
    frameToFill:Hide()
end

function AZP.LevelingStatistics:Round(x)
    return math.floor(x + 0.5)
end

if not IsAddOnLoaded("AzerPUGsCore") then
    AZP.LevelingStatistics:OnLoadSelf()
end

AZP.SlashCommands["LS"] = function()
    print("SlashCommand Called!")
    if AZPLSSelfFrame ~= nil then AZP.LevelingStatistics:ShowHideFrame() end
end

AZP.SlashCommands["ls"] = AZP.SlashCommands["LS"]
AZP.SlashCommands["level"] = AZP.SlashCommands["LS"]
AZP.SlashCommands["leveling statistics"] = AZP.SlashCommands["LS"]