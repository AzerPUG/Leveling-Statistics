if AZP == nil then AZP = {} end
if AZP.VersionControl == nil then AZP.VersionControl = {} end
if AZP.OnLoad == nil then AZP.OnLoad = {} end
if AZP.OnEvent == nil then AZP.OnEvent = {} end
if AZP.OnEvent == nil then AZP.OnEvent = {} end

AZP.VersionControl.LevelingStatistics = 9
AZP.LevelingStatistics = {}

local initialConfig = AGU.initialConfig

local dash = " - "
local name = "GameUtility" .. dash .. "LevelStats"
local nameFull = ("AzerPUG " .. name)
local promo = (nameFull .. dash ..  AZPGULevelStatsVersion)

local ModuleStats = AZP.Core.ModuleStats        -- Change to direct call!

local xpMax = 0
local xpCur = 0
local xpGained = 0
local xpNeed = 0
local curLevel = 0
local startTime = 0

function AZP.VersionControl:LevelingStatistics()
    return AZPGULevelStatsVersion
end

function AZP.OnLoad:LevelingStatistics()
    ModuleStats["Frames"]["LevelingStatistics"]:SetSize(250, 100)
    AZP.LevelingStatistics:ChangeOptionsText()
    GameUtilityAddonFrame:RegisterEvent("PLAYER_XP_UPDATE")
    ModuleStats["Frames"]["LevelingStatistics"].contentText = ModuleStats["Frames"]["LevelingStatistics"]:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ModuleStats["Frames"]["LevelingStatistics"].contentText:SetText("No EXP Gained Yet.")
    ModuleStats["Frames"]["LevelingStatistics"].contentText:SetPoint("LEFT", 10, 0)
    ModuleStats["Frames"]["LevelingStatistics"].contentText:SetSize(250, 100)
    ModuleStats["Frames"]["LevelingStatistics"].contentText:SetJustifyH("LEFT")

    xpMax = UnitXPMax("player")
    xpCur = UnitXP("player")
    xpNeed = xpGained - xpCur
    curLevel = UnitLevel("player")
    startTime = time()
end

function AZP.LevelingStatistics:UpdateXP()
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

    ModuleStats["Frames"]["LevelingStatistics"].contentText:SetText(
        "XP Stats:\n" ..
        "Current: " .. AZP.LevelingStatistics:Round(xpCur / 1000) .. "k / " .. AZP.LevelingStatistics:Round(xpMax / 1000) .. "k. (" .. AZP.LevelingStatistics:Round(xpCur / xpMax * 100) .. "%)\n" ..
        xpGained .. " Total XP Gained.\n" ..
        "XP / Hour: " .. AZP.LevelingStatistics:Round(xpGained / 1000 / (timeDifference / 3600)) .. "k.\n" ..
        AZP.LevelingStatistics:Round(xpNeed / AZP.LevelingStatistics:Round(xpGained / (timeDifference / 60))) .. " min to level " .. (curLevel + 1) .. ".\n" ..
        "Aprox " .. AZP.LevelingStatistics:Round(xpMax / AZP.LevelingStatistics:Round(xpGained / (timeDifference / 60))) .. " minutes / level."
    )
end

function AZP.OnEvent:LevelingStatistics(event, ...)
    if event == "PLAYER_XP_UPDATE" then
        AZP.LevelingStatistics:UpdateXP()
    end
end

function AZP.LevelingStatistics:Round(x)
    return math.floor(x + 0.5)
end

AZP.SlashCommands["LS"] = function()
    if LevelingStatisticsSelfFrame ~= nil then LevelingStatisticsSelfFrame:Show() end
end

AZP.SlashCommands["ls"] = AZP.SlashCommands["LS"]
AZP.SlashCommands["level"] = AZP.SlashCommands["LS"]
AZP.SlashCommands["leveling statistics"] = AZP.SlashCommands["LS"]