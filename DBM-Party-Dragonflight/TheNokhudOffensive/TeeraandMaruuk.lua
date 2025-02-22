local mod	= DBM:NewMod(2478, "DBM-Party-Dragonflight", 3, 1198)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(186339, 186338)
mod:SetEncounterID(2581)
mod:SetBossHPInfoToHighest()
mod:SetHotfixNoticeRev(20221127000000)
mod:SetMinSyncRevision(20221105000000)
--mod.respawnTime = 29

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 382670 386063 385339 386547 385434 382836",
	"SPELL_AURA_APPLIED 384808 392198",
	"SPELL_AURA_REMOVED 392198",
	"UNIT_DIED"
)

--[[
(ability.id = 382670 or ability.id = 386063 or ability.id = 385339 or ability.id = 386547 or ability.id = 385434 or ability.id = 382836) and type = "begincast"
 or (target.id = 186339 or target.id = 186338) and type = "death"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or type = "interrupt"
--]]
--General
local timerRP									= mod:NewRPTimer(34.4)
--Teera
mod:AddTimerLine(DBM:EJ_GetSectionInfo(25552))
local warnRepel									= mod:NewCastAnnounce(386547, 3, nil, nil, nil, nil, nil, 2)
local warnSpiritLeap							= mod:NewSpellAnnounce(385434, 3)

local specWarnGaleArrow							= mod:NewSpecialWarningDodgeCount(382670, nil, nil, nil, 2, 2)
local specWarnGuardianWind						= mod:NewSpecialWarningInterrupt(384808, "HasInterrupt", nil, nil, 1, 2)

local timerGaleArrowCD							= mod:NewCDCountTimer(57.4, 382670, nil, nil, nil, 3)
local timerRepelCD								= mod:NewCDCountTimer(57.4, 386547, nil, nil, nil, 4, nil, DBM_COMMON_L.INTERRUPT_ICON)
local timerSpiritLeapCD							= mod:NewCDCountTimer(20.4, 385434, nil, nil, nil, 3)--20-38.4 (if guardian wind isn't interrupted this can get delayed by repel recast)

--Maruuk
mod:AddTimerLine(DBM:EJ_GetSectionInfo(25546))
local warnFrightfulRoar							= mod:NewCastAnnounce(386063, 3, nil, nil, nil, nil, nil, 2)--Not a special warning, since I don't want to layer 2 special warings for same pair

local specWarnEarthsplitter						= mod:NewSpecialWarningDodgeCount(385339, nil, nil, nil, 2, 2)
local specWarnFrightfulRoar						= mod:NewSpecialWarningRun(386063, nil, nil, nil, 4, 2)
local specWarnBrutalize							= mod:NewSpecialWarningDefensive(382836, nil, nil, nil, 1, 2)

local timerEarthSplitterCD						= mod:NewCDCountTimer(57.4, 385339, nil, false, nil, 3, nil, DBM_COMMON_L.DEADLY_ICON)--Off by default since it should always be cast immediately after Repel)
local timerFrightfulRoarCD						= mod:NewCDCountTimer(30.4, 386063, nil, nil, nil, 2, nil, DBM_COMMON_L.MAGIC_ICON)--New timer unknown
local timerBrutalizeCD							= mod:NewCDCountTimer(18.2, 382836, nil, "Tank|Healer", nil, 5, nil, DBM_COMMON_L.TANK_ICON)--Delayed a lot. Doesn't alternate or sequence leanly, it just spell queues in randomness

mod:AddNamePlateOption("NPAuraOnAncestralBond", 392198)

--Gale Arrow: 21.5, 57.4, 57.5
--Repel: 50, 57.4, 57.5
--Spirit Leap: 6.0, 24.0, 13.5, 19.9, 24.0, 13.5, 20.0, 23.9, 13.5
--Earth Splitter: 51, 57.4, 57.5
--Frightful Roar: 5.5, 38.4, 18.9, 38.4, 19, 38.5
--Brutalize: 13.5, 7.4, 15.9, 34.0, 7.4, 15.9, 34.0, 7.5, 15.9
--Static Counts
mod.vb.galeCount = 0
mod.vb.repelCount = 0
mod.vb.splitterCount = 0
--Sequenced counts
mod.vb.leapCount = 0
mod.vb.roarCount = 0
mod.vb.brutalizeCount = 0

local function scanBosses(self, delay)
	for i = 1, 2 do
		local unitID = "boss"..i
		if UnitExists(unitID) then
			local cid = self:GetUnitCreatureId(unitID)
			local bossGUID = UnitGUID(unitID)
			if cid == 193435 then--Terra
				timerSpiritLeapCD:Start(6-delay, 1, bossGUID)
				timerGaleArrowCD:Start(21.5-delay, 1, bossGUID)
				timerRepelCD:Start(50-delay, 1, bossGUID)
			else--Maruuk
				timerFrightfulRoarCD:Start(5.5-delay, 1, bossGUID)
				timerBrutalizeCD:Start(13.5-delay, 1, bossGUID)
				timerEarthSplitterCD:Start(51-delay, 1, bossGUID)
			end
		end
	end
end

function mod:OnCombatStart(delay)
	--Static Counts
	self.vb.galeCount = 0
	self.vb.repelCount = 0
	self.vb.splitterCount = 0
	--Sequenced counts
	self.vb.leapCount = 0
	self.vb.roarCount = 0
	self.vb.brutalizeCount = 0
	self:Schedule(1, scanBosses, self, delay)--1 second delay to give IEEU time to populate boss guids
	if self.Options.NPAuraOnAncestralBond then
		DBM:FireEvent("BossMod_EnableHostileNameplates")
	end
end

function mod:OnCombatEnd()
	if self.Options.NPAuraOnAncestralBond then
		DBM.Nameplate:Hide(true, nil, nil, nil, true, true)
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 382670 then
		self.vb.galeCount = self.vb.galeCount + 1
		specWarnGaleArrow:Show(self.vb.galeCount)
		specWarnGaleArrow:Play("watchstep")
		timerGaleArrowCD:Start(nil, self.vb.galeCount+1, args.sourceGUID)
	elseif spellId == 386063 then
		self.vb.roarCount = self.vb.roarCount + 1
		if self.Options.SpecWarn386063run then
			specWarnFrightfulRoar:Show()
			specWarnFrightfulRoar:Play("justrun")
			specWarnFrightfulRoar:ScheduleVoice(1, "fearsoon")
		else
			warnFrightfulRoar:Show()
			warnFrightfulRoar:Play("fearsoon")
		end
		local timer
		--Frightful Roar: 5.5, 38.4, 18.9, 38.4, 19, 38.5
		if self.vb.roarCount % 2 == 0 then--2, 4, 6, etc
			timer = 18.9
		else
			timer = 38.4
		end
		timerFrightfulRoarCD:Start(timer, self.vb.roarCount+1, args.sourceGUID)
	elseif spellId == 385339 then
		self.vb.splitterCount = self.vb.splitterCount + 1
		specWarnEarthsplitter:Show(self.vb.splitterCount)
		specWarnEarthsplitter:Play("watchstep")
		timerEarthSplitterCD:Start(nil, self.vb.splitterCount+1, args.sourceGUID)
	elseif spellId == 386547 then
		self.vb.repelCount = self.vb.repelCount + 1
		warnRepel:Show(self.vb.repelCount)
		warnRepel:Play("carefly")
		timerRepelCD:Start(nil, self.vb.repelCount+1, args.sourceGUID)
	elseif spellId == 385434 then
		self.vb.leapCount = self.vb.leapCount + 1
		warnSpiritLeap:Show()
		local timer
		--Spirit Leap: 6.0, 24.0, 13.5, 19.9, 24.0, 13.5, 20.0, 23.9, 13.5
		if self.vb.leapCount % 3 == 0 then--3, 6, 9, etc
			timer = 19.9
		elseif self.vb.leapCount % 3 == 1 then--1, 4, 7, etc
			timer = 23.9
		else--2, 5, 8, etc
			timer = 13.4
		end
		timerSpiritLeapCD:Start(timer, self.vb.leapCount+1, args.sourceGUID)
	elseif spellId == 382836 then
		self.vb.brutalizeCount = self.vb.brutalizeCount + 1
		if self:IsTanking("player", nil, nil, true, args.sourceGUID) then
			specWarnBrutalize:Show()
			specWarnBrutalize:Play("defensive")
		end
		local timer
		--Brutalize: 13.5, 7.4, 15.9, 34.0, 7.4, 15.9, 34.0, 7.5, 15.9
		if self.vb.brutalizeCount % 3 == 0 then--3, 6, 9, etc
			timer = 34
		elseif self.vb.brutalizeCount % 3 == 1 then--1, 4, 7, etc
			timer = 7.4
		else--2, 5, 8, etc
			timer = 15.9
		end
		timerBrutalizeCD:Start(timer, self.vb.brutalizeCount+1, args.sourceGUID)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 384808 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specWarnGuardianWind:Show(args.sourceName)
		specWarnGuardianWind:Play("kickcast")
	elseif spellId == 392198 then
		if self.Options.NPAuraOnAncestralBond then
			DBM.Nameplate:Show(true, args.destGUID, spellId)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 392198 then
		if self.Options.NPAuraOnAncestralBond then
			DBM.Nameplate:Hide(true, args.destGUID, spellId)
		end
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 186339 then--Teera
		timerGaleArrowCD:Stop()
		timerRepelCD:Stop()
		timerSpiritLeapCD:Stop()
	elseif cid == 186338 then--Maruuk
		timerEarthSplitterCD:Stop()
		timerFrightfulRoarCD:Stop()
		timerBrutalizeCD:Stop()
	end
end

--"<67.75 20:59:56> [CLEU] SPELL_AURA_APPLIED#Creature-0-3019-2516-29682-186338-00007D601C#Maruuk#Creature-0-3019-2516-29682-186339-00007D601C#Teera#345561#Life Link#DEBUFF#nil", -- [445]
--"<67.75 20:59:56> [CLEU] SPELL_AURA_APPLIED#Creature-0-3019-2516-29682-186339-00007D601C#Teera#Creature-0-3019-2516-29682-186338-00007D601C#Maruuk#345561#Life Link#DEBUFF#nil", -- [446]
--"<67.90 20:59:56> [CHAT_MSG_MONSTER_YELL] Why has our rest been disturbed?#Teera###Omegal##0#0##0#1387#nil#0#false#false#false#false", -- [447]
--"<88.73 21:00:17> [CHAT_MSG_MONSTER_YELL] Necromancers? On our sacred grounds?#Teera###Gravelord Monkh##0#0##0#1388#nil#0#false#false#false#false", -- [468]
--"<94.47 21:00:23> [CHAT_MSG_MONSTER_YELL] This is what has become of our legacy?#Maruuk###Gravelord Monkh##0#0##0#1389#nil#0#false#false#false#false", -- [473]
--"<95.30 21:00:24> [DBM_Debug] ENCOUNTER_START event fired: 2581 Teera and Maruuk 1 5#nil", -- [474]
function mod:OnSync(msg)
	if msg == "TeeraRP" and self:AntiSpam(10, 9) then--Sync sent from trash mod since trash mod is already monitoring out of combat CLEU events
		timerRP:Start(26.7)
	end
end
