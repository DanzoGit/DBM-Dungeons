local mod	= DBM:NewMod(2503, "DBM-Party-Dragonflight", 7, 1202)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(190484, 190485)
mod:SetEncounterID(2623)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20230109000000)
--mod:SetMinSyncRevision(20211203000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 381605 381602 381525 381517 381512 385558 381516",
	"SPELL_CAST_SUCCESS 381517",
	"SPELL_AURA_APPLIED 381515 181089 381862",
	"UNIT_DIED"
)

--[[
(ability.id = 381605 or ability.id = 381602 or ability.id = 381525 or ability.id = 381517 or ability.id = 381512 or ability.id = 385558 or ability.id = 381516) and type = "begincast"
 or type = "death" and (target.id = 193435 or target.id = 190485)
 or ability.id = 181089
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
--]]
--Kyrakka
mod:AddTimerLine(DBM:EJ_GetSectionInfo(25365))
local warnFlamespit								= mod:NewTargetNoFilterAnnounce(381605, 3)
local warnInfernoCore							= mod:NewYouAnnounce(381862, 4)

local yellFlamespit								= mod:NewYell(381605)
local specWarnInfernoCore						= mod:NewSpecialWarningMoveAway(381862, nil, nil, nil, 1, 2)
local specWarnRoaringFirebreath					= mod:NewSpecialWarningDodge(381525, nil, nil, nil, 2, 2)

local timerFlamespitCD							= mod:NewCDTimer(15.7, 381605, nil, nil, nil, 3)
local timerRoaringFirebreathCD					= mod:NewCDTimer(18, 381525, nil, nil, nil, 3)
--Erkhart Stormvein
mod:AddTimerLine(DBM:EJ_GetSectionInfo(25369))
local warnWindsofChange							= mod:NewCountAnnounce(381517, 3, nil, nil, 227878)--Not actually a count timer, but has best localized text
local warnCloudburst							= mod:NewSpellAnnounce(385558, 3)

local specWarnStormslam							= mod:NewSpecialWarningDefensive(381512, nil, nil, nil, 1, 2)
local specWarnStormslamDispel					= mod:NewSpecialWarningDispel(381512, "RemoveMagic", nil, nil, 1, 2)
local specWarnInterruptingCloudburst			= mod:NewSpecialWarningCast(381516, "SpellCaster", nil, nil, 2, 2, 4)

local timerWindsofChangeCD						= mod:NewCDCountTimer(19.3, 381517, 227878, nil, nil, 3)--Not actually a count timer, but has best localized text
local timerStormslamCD							= mod:NewCDTimer(17, 381512, nil, "Tank|RemoveMagic", nil, 5, nil, DBM_COMMON_L.TANK_ICON..DBM_COMMON_L.MAGIC_ICON)
local timerCloudburstCD							= mod:NewCDTimer(19.3, 385558, nil, nil, nil, 2)--Used for both mythic and non mythic versions of spell

mod:AddInfoFrameOption(381862, false)--Infernocore

mod.vb.windDirection = 0

function mod:SpitTarget(targetname)
	if not targetname then return end
	warnFlamespit:Show(targetname)
	if targetname == UnitName("player") then
		yellFlamespit:Yell()
	end
end

--Count started at 0 because count is incremented in success event not start
local directions = {
	[0] = L.North,
	[1] = L.West,
	[2] = L.South,
	[3] = L.East
}

local function scanBosses(self, delay)
	for i = 1, 2 do
		local unitID = "boss"..i
		if UnitExists(unitID) then
			local cid = self:GetUnitCreatureId(unitID)
			local bossGUID = UnitGUID(unitID)
			if cid == 193435 then--Kyrakka
				timerRoaringFirebreathCD:Start(1.1-delay, bossGUID)
				timerFlamespitCD:Start(16.1-delay, bossGUID)--17-24?
			else--Erkhart Stormvein
				timerStormslamCD:Start(4-delay, bossGUID)
				timerCloudburstCD:Start(8.4-delay, bossGUID)
			end
		end
	end
end

function mod:OnCombatStart(delay)
	self.vb.windDirection = 0
	self:SetStage(1)
	timerWindsofChangeCD:Start(17.1-delay, L.North)
	self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
	if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(DBM:GetSpellInfo(381862))
		DBM.InfoFrame:Show(5, "playerdebuffremaining", 381862)
	end
end

function mod:OnCombatEnd()
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 381605 or spellId == 381602 then--One is for bosses split and one is for bosses combined.
		self:ScheduleMethod(0.2, "BossTargetScanner", args.sourceGUID, "SpitTarget", 0.1, 8, true)
		timerFlamespitCD:Start(self:GetStage(1) and 21.1 or 15, args.sourceGUID)
	elseif spellId == 381525 then
		specWarnRoaringFirebreath:Show()
		specWarnRoaringFirebreath:Play("breathsoon")
		timerRoaringFirebreathCD:Start(18, args.sourceGUID)--18-27
	elseif spellId == 381517 then
		warnWindsofChange:Show(directions[self.vb.windDirection])
	elseif spellId == 381512 then
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then--Using GUID check because might be boss1 or boss2
			specWarnStormslam:Show()
			specWarnStormslam:Play("defensive")
		end
		timerStormslamCD:Start(nil, args.sourceGUID)--self:GetStage(1) and 10 or 14
	elseif spellId == 385558 or spellId == 381516 then
		if spellId == 381516 and self.Options.SpecWarn381516cast then--Mythic
			specWarnInterruptingCloudburst:Show()
			specWarnInterruptingCloudburst:Play("stopcast")
		else--Normal/Heroic
			warnCloudburst:Show()
		end
		timerCloudburstCD:Start(nil, args.sourceGUID)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 381517 then--Here because boss can stutter cast and start cast over
		self.vb.windDirection = self.vb.windDirection + 1
		if self.vb.windDirection == 4 then
			self.vb.windDirection = 0
		end
		timerWindsofChangeCD:Start(17.8, directions[self.vb.windDirection])
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 381515 and self:CheckDispelFilter("magic") then
		specWarnStormslamDispel:Show(args.destName)
		specWarnStormslamDispel:Play("helpdispel")
	elseif spellId == 181089 then
		self:SetStage(2)
		--Timers reset by staging
		for i = 1, 2 do
			local unitID = "boss"..i
			if UnitExists(unitID) then
				local cid = self:GetUnitCreatureId(unitID)
				if cid == 193435 then--Kyrakka
					local bossGUID = UnitGUID(unitID)
					timerFlamespitCD:Restart(2.2, UnitGUID)--3.6 now?
					timerRoaringFirebreathCD:Restart(7.3, UnitGUID)--9.7 now?
					break
				end
			end
		end
		--Rest not reset
	elseif spellId == 381862 and args:IsPlayer() then
		if self.Options.SpecWarn381862moveaway and self:AntiSpam(3, 1) then
			specWarnInfernoCore:Show()
			specWarnInfernoCore:Play("runout")
		else
			warnInfernoCore:Show()
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 193435 then--Kyrakka
		timerFlamespitCD:Stop(args.destGUID)
		timerRoaringFirebreathCD:Stop(args.destGUID)
	elseif cid == 190485 then--Erkhart
		timerWindsofChangeCD:Stop(args.destGUID)
		timerStormslamCD:Stop(args.destGUID)
		timerCloudburstCD:Stop(args.destGUID)
	end
end
