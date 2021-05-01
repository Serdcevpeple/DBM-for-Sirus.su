local mod	= DBM:NewMod("Hodir", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")
mod:SetCreatureID(32845)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE"
)

local warnStormCloud		= mod:NewTargetAnnounce(312831) --Грозовая туча

local warnFlashFreeze		= mod:NewSpecialWarningSpell(312818, nil, nil, nil, 3, 2)
local specWarnStormCloud	= mod:NewSpecialWarningYou(65123, nil, nil, nil, 1, 2)
local yellStormCloud		= mod:NewYell(65133)
local specWarnBitingCold	= mod:NewSpecialWarningMove(312819, nil, nil, nil, 1, 2)


local enrageTimer			= mod:NewBerserkTimer(475)
local timerFlashFreeze		= mod:NewCastTimer(9, 312818, nil, nil, nil, 2)
local timerFrozenBlows		= mod:NewBuffActiveTimer(20, 312816, 63512, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON..DBM_CORE_HEALER_ICON)
local timerFlashFrCD		= mod:NewCDTimer(50, 312818, nil, nil, nil, 2)
local timerAchieve			= mod:NewAchievementTimer(179, 3182, "TimerSpeedKill")

mod:AddSetIconOption("SetIconOnStormCloud", 65123, true, false, {8, 7})

mod.vb.stormCloudIcon = 8

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32845, "Hodir")
	enrageTimer:Start()
	timerAchieve:Start()
	timerFlashFrCD:Start(-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33113, "FlameLeviathan", wipe)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(312818,312465) then  --Ледяная вспышка
		timerFlashFreeze:Start()
		warnFlashFreeze:Show()
		timerFlashFrCD:Start()
		if self.Options.PlaySoundOnFlashFreeze then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312817, 312816,312464,312463) then --Ледяные дуновения
		timerFrozenBlows:Start()
	elseif args:IsSpellID(312831, 312478) then -- Грозовая туча
		if args:IsPlayer() then
			specWarnStormCloud:Show()
			specWarnStormCloud:Play("gathershare")
			yellStormCloud:Yell()
		else
			warnStormCloud:Show(args.destName)
		end
		if self.Options.SetIconOnStormCloud then
			self:SetIcon(args.destName, self.vb.stormCloudIcon)
		end
		if self.vb.stormCloudIcon == 8 then	-- There is a chance 2 ppl will have the buff on 25 player, so we are alternating between 2 icons
			self.vb.stormCloudIcon = 7
		else
			self.vb.stormCloudIcon = 8
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(312831, 312478) then
		if self.Options.SetIconOnStormCloud then
			self:SetIcon(args.destName, 0)
		end
	end
end


function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(312819, 312466) and args:IsPlayer() and self:AntiSpam(4) then		-- Трескучий мороз
		specWarnBitingCold:Show()
		specWarnBitingCold:Play("keepmove")
	end
end
