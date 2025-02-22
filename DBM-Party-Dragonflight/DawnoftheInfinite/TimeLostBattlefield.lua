local creatureID
local addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId
if UnitFactionGroup("player") == "Alliance" then--TODO, might have to change this to check party leader not player, due to cross faction groups.
	creatureID = 203679--Anduin Lothar
	addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId = 417018, 417030, 418059, 418054, 418047, 418062
else--Horde
	creatureID = 203678--Grommash Hellscream
	addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId = 407122, 407121, 410254, 408227, 418046, 410496
end
local mod	= DBM:NewMod(2533, "DBM-Party-Dragonflight", 9, 1209)--Alliance ID used, horde is 2534
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(creatureID)
mod:SetEncounterID(2672)
--mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20231102000000)
mod:SetMinSyncRevision(20231102000000)
--mod.respawnTime = 29
mod.sendMainBossGUID = true

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 417018 407122 410234 418059 410254 418056 408228 418047 418046",
	"SPELL_CAST_SUCCESS 418054 408227",--418062 410496
	"SPELL_AURA_APPLIED 417030 407121",
--	"SPELL_AURA_APPLIED_DOSE",
--	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE 418052 410496",
	"SPELL_MISSED 418052 410496",
	"UNIT_DIED"
--	"UNIT_SPELLCAST_SUCCEEDED boss1"
)

--[[
(ability.id = 417018 or ability.id = 407122 or ability.id = 410234 or ability.id = 418059 or ability.id = 410254 or ability.id = 418056 or ability.id = 408228 or ability.id = 418047 or ability.id = 418046) and type = "begincast"
 or (ability.id = 418062 or ability.id = 410496 or ability.id = 418054 or ability.id = 408227) and type = "cast"
 or type = "dungeonencounterstart" or type = "dungeonencounterend"
 or (ability.id = 418052 or ability.id = 410496)
 or (ability.id = 417030 or ability.id = 407121 or ability.id = 407122 or ability.id = 410234) and type = "begincast"
--]]
--NOTE: Serrated and fireball abilities are spammed, so no timer or alert
--TODO, Blizzard decided to remove Cry from combat log on live because, reasons. Now we have to parse all damage on fight to see CD
--TODO, GTFO for add aoe? Logs I had nobody took damage from it so couldn't do yet
--TODO, targetscan/detect bladestorm target?
--The Infinite Battlefield
mod:AddTimerLine(DBM:EJ_GetSectionInfo(26514))
local warnAddAoE									= mod:NewSpellAnnounce(addAOESpellId, 3)
local warnAddDebuff									= mod:NewTargetNoFilterAnnounce(addDebuffSpellId, 3, nil, false)

--local specWarnManaBomb							= mod:NewSpecialWarningMoveAway(386181, nil, nil, nil, 1, 2)
--local yellManaBomb								= mod:NewYell(386181)
--local yellManaBombFades							= mod:NewShortFadesYell(386181)
--local specWarnGTFO								= mod:NewSpecialWarningGTFO(386201, nil, nil, nil, 1, 8)

local timerAddAoECD									= mod:NewCDNPTimer(12.1, addAOESpellId, nil, nil, nil, 3)

--mod:AddInfoFrameOption(391977, true)
--Boss (Anduin Lothar / Grommash Hellscream
mod:AddTimerLine(DBM_COMMON_L.BOSS)
local warnBladestorm								= mod:NewCountAnnounce(410235, 3, nil, nil, nil, nil, nil, 2)
local warnRally										= mod:NewCountAnnounce(rallySpellId, 2)
local warnCry										= mod:NewCountAnnounce(crySpellId, 2)
local warnShockwave									= mod:NewCountAnnounce(shockwaveSpellId, 3)--2nd and 3rd cast

local specWarnBladestorm							= mod:NewSpecialWarningDodgeCount(410235, "Melee", nil, nil, 2, 2)
local specWarnTankBuster							= mod:NewSpecialWarningDefensive(tankSpellId, nil, nil, nil, 1, 2)
local specWarnShockwave								= mod:NewSpecialWarningDodge(shockwaveSpellId, nil, nil, nil, 2, 2)--First cast in set

local timerBladestormCD								= mod:NewCDCountTimer(35.1, 410235, nil, nil, nil, 3)
local timerTankBusterCD								= mod:NewCDCountTimer(19.6, tankSpellId, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerShockwaveCD								= mod:NewCDCountTimer(35.1, shockwaveSpellId, nil, nil, nil, 3)
local timerRallyCD									= mod:NewCDCountTimer(20.8, rallySpellId, nil, nil, nil, 5)--For the X
local timerCryCD									= mod:NewCDCountTimer(10, crySpellId, nil, nil, nil, 2)

--Write the custom WA keys into the spell headers
mod:JustSetCustomKeys(rallySpellId, L.customWAMessage:format(418047, 418046))
mod:JustSetCustomKeys(crySpellId, L.customWAMessage:format(418062, 410496))
mod:JustSetCustomKeys(shockwaveSpellId, L.customWAMessage:format(418054, 408227))
mod:JustSetCustomKeys(tankSpellId, L.customWAMessage:format(418059, 410254))

mod.vb.bladestormCount = 0
mod.vb.shockwaveSet = 0
mod.vb.shockwaveCount = 0
mod.vb.tankBusterCount = 0
mod.vb.rallyCount = 0
mod.vb.cryCount = 0

local function checkWhichBoss(self)
	local cid = self:GetUnitCreatureId("boss1")
	if cid then
		--Only do swaps if they differ from last check or load
		if cid ~= creatureID then--cid mismatch, correct it on engage
			creatureID = cid
			self:SetCreatureID(cid)
			--This hot swaps the Ids without changing option key, which is always tied to own faction
			--This ensures objects return the faction Ids for what you're fighting, (which is tied to group leader and not your own faction)
			--This also ensures LW parity for option keys/weak auras
			if cid == 203679 then--Anduin Lothar
				addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId = 417018, 417030, 418059, 418054, 418047, 418062
			else--Grommash Hellscream
				addAOESpellId, addDebuffSpellId, tankSpellId, shockwaveSpellId, rallySpellId, crySpellId = 407122, 407121, 410254, 408227, 418046, 410496
			end
			warnRally:UpdateKey(rallySpellId)
			warnCry:UpdateKey(crySpellId)
			warnShockwave:UpdateKey(shockwaveSpellId)
			warnAddAoE:UpdateKey(addAOESpellId)
			warnAddDebuff:UpdateKey(addDebuffSpellId)

			specWarnTankBuster:UpdateKey(tankSpellId)
			specWarnShockwave:UpdateKey(shockwaveSpellId)

			timerTankBusterCD:UpdateKey(tankSpellId, 1)
			timerShockwaveCD:UpdateKey(shockwaveSpellId, 1)
			timerRallyCD:UpdateKey(rallySpellId, 1)
			timerCryCD:UpdateKey(crySpellId, 1)
			timerAddAoECD:UpdateKey(addAOESpellId)
		end
	end
end

--Shockwave triggers 10.2 ICD on everything
--Bladestorm triggers a 12.1 ICD only on tank buster (even if no other abilities are in between), it triggers 8.5 on Rally ability
--Cry is unaffected by ICDs, it's off GCD and just always every 10 sec
local function updateAllTimers(self, ICD, isBladeStorm)
	DBM:Debug("updateAllTimers running", 3)
	if timerTankBusterCD:GetRemaining(self.vb.tankBusterCount+1) < (isBladeStorm and 12.1 or ICD) then
		local elapsed, total = timerTankBusterCD:GetTime(self.vb.tankBusterCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerTankBusterCD extended by: "..extend, 2)
		timerTankBusterCD:Update(elapsed, total+extend, self.vb.tankBusterCount+1)
	end
	if timerRallyCD:GetRemaining(self.vb.rallyCount+1) < ICD then
		local elapsed, total = timerRallyCD:GetTime(self.vb.rallyCount+1)
		local extend = ICD - (total-elapsed)
		DBM:Debug("timerRallyCD extended by: "..extend, 2)
		timerRallyCD:Update(elapsed, total+extend, self.vb.rallyCount+1)
	end
	--Needs more data, but unlikely any spell as higher spell queue priority than bladestorm so I don't think it applies
--	if timerBladestormCD:GetRemaining(self.vb.bladestormCount+1) < ICD then
--		local elapsed, total = timerBladestormCD:GetTime(self.vb.bladestormCount+1)
--		local extend = ICD - (total-elapsed)
--		DBM:Debug("timerBladestormCD extended by: "..extend, 2)
--		timerBladestormCD:Update(elapsed, total+extend, self.vb.bladestormCount+1)
--	end
	--Needs more data, but hasn't been witnessed
--	if timerShockwaveCD:GetRemaining(self.vb.shockwaveSet+1) < ICD then
--		local elapsed, total = timerShockwaveCD:GetTime(self.vb.shockwaveSet+1)
--		local extend = ICD - (total-elapsed)
--		DBM:Debug("timerShockwaveCD extended by: "..extend, 2)
--		timerShockwaveCD:Update(elapsed, total+extend, self.vb.shockwaveSet+1)
--	end
end

function mod:OnCombatStart(delay)
	self.vb.bladestormCount = 0
	self.vb.shockwaveSet = 0
	self.vb.shockwaveCount = 0
	self.vb.tankBusterCount = 0
	self.vb.rallyCount = 0
	self.vb.cryCount = 0
	timerTankBusterCD:Start(6-delay, 1)--Mortal Strikes/Decapitate
	timerShockwaveCD:Start(9.4-delay, 1)--Shockwave
	timerCryCD:Start(10.3-delay)--Battle Cry/War Cry
	timerRallyCD:Start(19.9-delay, 1)--For the alliance/horde
	timerBladestormCD:Start(21.5-delay, 1)
	self:Schedule(1.5, checkWhichBoss, self)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 417018 or spellId == 407122 then--Blizzard / Rain of Fire
		warnAddAoE:Show()
		timerAddAoECD:Start(nil, args.sourceGUID)
	elseif spellId == 410234 then--Same spell in both
		self.vb.bladestormCount = self.vb.bladestormCount + 1
		if self.Options.SpecWarn410234dodgecount then
			specWarnBladestorm:Show(self.vb.bladestormCount)
			specWarnBladestorm:Play("whirlwind")
		else
			warnBladestorm:Show(self.vb.bladestormCount)
			warnBladestorm:Play("whirlwind")
		end
		timerBladestormCD:Start(nil, self.vb.bladestormCount+1)
		updateAllTimers(self, 8.5, true)
	elseif spellId == 418059 or spellId == 410254 then--Mortal Strikes / Decapitate
		self.vb.tankBusterCount = self.vb.tankBusterCount + 1
		if self:IsTanking("player", "boss1", nil, true) then
			specWarnTankBuster:Show()
			specWarnTankBuster:Play("defensive")
		end
		timerTankBusterCD:Start(nil, self.vb.tankBusterCount+1)
	elseif spellId == 418056 or spellId == 408228 then--Shockwave / Shockwave (formerly Death Wish)
		self.vb.shockwaveCount = self.vb.shockwaveCount + 1
		if self.vb.shockwaveCount == 1 then
			self.vb.shockwaveSet = self.vb.shockwaveSet + 1
			specWarnShockwave:Show(self.vb.shockwaveSet)
			specWarnShockwave:Play("shockwave")
		else
			warnShockwave:Show(self.vb.shockwaveSet)
			if self.vb.shockwaveCount == 3 then
				--Timer moved to other event
--				timerShockwaveCD:Start(nil, self.vb.shockwaveSet+1)
				self.vb.shockwaveCount = 0
			end
		end
	elseif spellId == 418047 or spellId == 418046 then--For the alliance, for the horde
		self.vb.rallyCount = self.vb.rallyCount + 1
		warnRally:Show(self.vb.rallyCount)
		timerRallyCD:Start(nil, self.vb.rallyCount+1)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 418054 or spellId == 408227 then
		--Timer now started here now that it's being used as an update timer method earlier
		timerShockwaveCD:Start(nil, self.vb.shockwaveSet+1)
		updateAllTimers(self, 10.2, false)
--	elseif spellId == 418062 or spellId == 410496 then--Battle Cry, War Cry
--		self.vb.cryCount = self.vb.cryCount + 1
--		warnCry:Show(self.vb.cryCount)
--		timerCryCD:Start(nil, self.vb.cryCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 417030 or spellId == 407121 then--Fireball / Immolate
		warnAddDebuff:Show(args.destName)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if (spellId == 418052 or spellId == 410496) and self:AntiSpam(5, 1) then--BattleCry Buff, Warcry Buff
		self.vb.cryCount = self.vb.cryCount + 1
		warnCry:Show(self.vb.cryCount)
		timerCryCD:Start(nil, self.vb.cryCount+1)
--	elseif spellId == 386201 and destGUID == UnitGUID("player") and self:AntiSpam(3, 2) then
--		specWarnGTFO:Show(spellName)
--		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 206351 or cid == 203857 then--Alliance Conjuror / Horde Warlock
		timerAddAoECD:Stop(args.destGUID)
--	elseif cid == 206352 or cid == 203799 then--Alliance Archer/Horde Axe Thrower

	end
end
