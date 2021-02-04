local GlobalAddonName, AGU = ...

local initialConfig = AGU.initialConfig

local AZPGULevelStatsVersion = 8
local dash = " - "
local name = "GameUtility" .. dash .. "LevelStats"
local nameFull = ("AzerPUG " .. name)
local promo = (nameFull .. dash ..  AZPGULevelStatsVersion)

local addonMain = LibStub("AceAddon-3.0"):NewAddon("GameUtility-LevelStats", "AceConsole-3.0")

local ModuleStats = AZP.GU.ModuleStats

local xpMax = 0
local xpCur = 0
local xpGained = 0
local xpNeed = 0
local curLevel = 0
local startTime = 0

function AZP.GU.VersionControl:LevelStats()
    return AZPGULevelStatsVersion
end

function AZP.GU.OnLoad:LevelStats()
    ModuleStats["Frames"]["LevelStats"]:SetSize(250, 100)
    addonMain:ChangeOptionsText()
    GameUtilityAddonFrame:RegisterEvent("PLAYER_XP_UPDATE")
    ModuleStats["Frames"]["LevelStats"].contentText = ModuleStats["Frames"]["LevelStats"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ModuleStats["Frames"]["LevelStats"].contentText:SetText("No EXP Gained Yet.")
    ModuleStats["Frames"]["LevelStats"].contentText:SetPoint("LEFT", 10, 0)
    ModuleStats["Frames"]["LevelStats"].contentText:SetSize(250, 100)
    ModuleStats["Frames"]["LevelStats"].contentText:SetJustifyH("LEFT")

    xpMax = UnitXPMax("player")
    xpCur = UnitXP("player")
    xpNeed = xpGained - xpCur
    curLevel = UnitLevel("player")
    startTime = time()
end

function addonMain:UpdateXP()
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

    ModuleStats["Frames"]["LevelStats"].contentText:SetText(
        "XP Stats:\n" ..
        "Current: " .. addonMain:Round(xpCur / 1000) .. "k / " .. addonMain:Round(xpMax / 1000) .. "k. (" .. addonMain:Round(xpCur / xpMax * 100) .. "%)\n" ..
        xpGained .. " Total XP Gained.\n" ..
        "XP / Hour: " .. addonMain:Round(xpGained / 1000 / (timeDifference / 3600)) .. "k.\n" ..
        addonMain:Round(xpNeed / addonMain:Round(xpGained / (timeDifference / 60))) .. " min to level " .. (curLevel + 1) .. ".\n" ..
        "Aprox " .. addonMain:Round(xpMax / addonMain:Round(xpGained / (timeDifference / 60))) .. " minutes / level."
    )
end

function AZP.GU.OnEvent:LevelStats(event, ...)
    if event == "PLAYER_XP_UPDATE" then
        addonMain:UpdateXP()
    end
end

function addonMain:Round(x)
    return math.floor(x + 0.5)
end

function addonMain:ChangeOptionsText()
    LevelStatsSubPanelPHTitle:Hide()
    LevelStatsSubPanelPHText:Hide()
    LevelStatsSubPanelPHTitle:SetParent(nil)
    LevelStatsSubPanelPHText:SetParent(nil)

    local LevelStatsSubPanelHeader = LevelStatsSubPanel:CreateFontString("LevelStatsSubPanelHeader", "ARTWORK", "GameFontNormalHuge")
    LevelStatsSubPanelHeader:SetText(promo)
    LevelStatsSubPanelHeader:SetWidth(LevelStatsSubPanel:GetWidth())
    LevelStatsSubPanelHeader:SetHeight(LevelStatsSubPanel:GetHeight())
    LevelStatsSubPanelHeader:SetPoint("TOP", 0, -10)

    local LevelStatsSubPanelText = LevelStatsSubPanel:CreateFontString("LevelStatsSubPanelText", "ARTWORK", "GameFontNormalHuge")
    LevelStatsSubPanelText:SetWidth(LevelStatsSubPanel:GetWidth())
    LevelStatsSubPanelText:SetHeight(LevelStatsSubPanel:GetHeight())
    LevelStatsSubPanelText:SetPoint("TOPLEFT", 0, -50)
    LevelStatsSubPanelText:SetText(
        "AzerPUG-GameUtility-LevelStats does not have options yet.\n" ..
        "For feature requests visit our Discord Server!"
    )
end