local addon, DBM_Disease = ...

local GetSpellInfo = C_Spell.GetSpellInfo

DBM_Disease.rotation.timer = {
  lag = 0
}

local gcd_spell = 61304
local gcd_spell_name = GetSpellInfo(61304)

local last_loading = GetTime()
local loading_wait = math.random(120, 300)
local last_duration = false
local lastLag = 0
local castclip = 0
local turbo = false
local hookCast = false


local function cstng()
    if UnitCastingInfo('player') or UnitChannelInfo('player') then
        return true
    end
    return false
end


local function getValidPotion(Potion_Items)
	for _, item in ipairs(Potion_Items) do
		---- print(item)
		if GetItemCount( item, false ) > 0 and GetItemCooldown(item) == 0  then 
			---- print(item, 'pass')
			return item 
		end
	end
    return nil
end

local function iknow(spellID)
    local isKnown = IsPlayerSpell(spellID, isPetSpell)
    local IsSpellKnown = IsSpellKnown(spellID, isPetSpell)
    local talent = DBM_Disease.rotation.allTalents[spellID]
    local isTalentActive = talent and talent.active or false

    if isKnown or IsSpellKnown or isTalentActive then
        return true 
    else 
        return false 
    end
end

local function isCasting()
	local casting, _, _, _, _, _, _, _, c_spellId = UnitCastingInfo('player')
	local channel, _, _, _, _, _, _, ch_spellId = UnitChannelInfo('player')
	if casting or channel then
		return true
	end
	return false
end


local function useItem(item)
if not item then return end
	local name = C_Item.GetItemInfo(item)
	if not name then return end
	local name = tostring(name);
	return UseItemByName(name)
end


local function items()
	if player.buff(255274).up then return end
	if player.buff(27827).up then return end
	local Trinket13                     = GetInventoryItemID("player", 13)
	local Trinket14                     = GetInventoryItemID("player", 14)
	local ring1                         = GetInventoryItemID("player", 11)
	local ring2                         = GetInventoryItemID("player", 12)
	local Trinkets_k                    = DBM_Disease.settings.fetch("global_settings_Trinkets_k")
	local Rings_k                       = DBM_Disease.settings.fetch("global_settings_Rings_k")
	local isEquipped13                  = GetInventoryItemID("player", 13)
	local isEquipped14                  = GetInventoryItemID("player", 14)
	local isEquipped11                  = GetInventoryItemID("player", 11)
	local isEquipped12                  = GetInventoryItemID("player", 12)
	local hands                         = GetInventoryItemID("player", 10)
	local WarlockFood_Check			    = DBM_Disease.settings.fetch("global_settings_WarlockFood.check", false)
	local WarlockFood_Spin	            = DBM_Disease.settings.fetch("global_settings_WarlockFood.spin", 85)
	local PotionsMana_Check				= DBM_Disease.settings.fetch("global_settings_PotionsMana.check", false)
	local PotionsMana_Spin	        	= DBM_Disease.settings.fetch("global_settings_PotionsMana.spin", 55)
	local PotionsHealth_Check			= DBM_Disease.settings.fetch("global_settings_PotionsHealth.check", false)
	local PotionsHealth_Spin	        = DBM_Disease.settings.fetch("global_settings_PotionsHealth.spin", 85)
	local ManaPotions                   = { 212241, 212240, 212239, 212244, 212243, 212242, 191384 }
	local HealthPotions                 = { 211880, 212244, 212243, 212242, 191378, 211879, 211878 } --wowhead
	
	
	
	
	if WarlockFood_Check and player.alive then  -- life save can interrupt channel
		if player.health.percent <= WarlockFood_Spin and GetItemCount(5512) >= 1 and GetItemCooldown(5512) == 0 then
			useItem(5512)
		end
	end

	if PotionsHealth_Check and player.alive then -- life save can interrupt channel
	local currentHealthPercent = player.health.percent
	if currentHealthPercent <= PotionsHealth_Spin then
		local potion = getValidPotion(HealthPotions)
			if potion then
				local _, cooldown = GetItemCooldown(potion)
				if cooldown == 0 then
					useItem(potion)
				end
			end
		end
	end
	
	if isCasting() then return end
	
	if PotionsMana_Check and player.alive then
		local currentManaPercent = player.power.mana.percent
		if currentManaPercent <= PotionsMana_Spin then
			local potion = getValidPotion(ManaPotions)
			if potion then
				local _, cooldown = GetItemCooldown(potion)
				if cooldown == 0 then
					useItem(potion)
				end
			end
		end
	end


	if UnitAffectingCombat("player") and not cstng() and target.exists and target.alive and target.enemy then
	if toggle('cooldowns', false) then
	if Trinkets_k == 'ot' then
		if isEquipped13 ~= nil and GetItemCooldown(Trinket13) == 0 then
			useItem(Trinket13)
		end

		if isEquipped14 ~= nil and GetItemCooldown(Trinket14) == 0 then
			useItem(Trinket14)
		end
	end

	if Trinkets_k == 'o' then
		if isEquipped13 ~= nil and GetItemCooldown(Trinket13) == 0 then
			useItem(Trinket13)
		end
	end
	if Trinkets_k == 't' then
		if isEquipped14 ~= nil and GetItemCooldown(Trinket14) == 0 then
			useItem(Trinket14)
		end
	end


	if Rings_k == 'ot' then
		if isEquipped11 ~= nil and GetItemCooldown(ring1) == 0 and not player.channeling() then
			useItem(ring1)
		end

		if isEquipped12 ~= nil and  GetItemCooldown(ring2) == 0 and not player.channeling() then
			useItem(ring2)
		end
	end

	if Rings_k == 'o' then
		if isEquipped11 ~= nil and GetItemCooldown(ring1) == 0 and not player.channeling() then
			useItem(ring1)
		end
	end
	if Rings_k == 't' then
		if isEquipped12 ~= nil and GetItemCooldown(ring2) == 0 and not player.channeling() then
			useItem(ring2)
		end
	end
	end
	end
end
setfenv(items, DBM_Disease.environment.env)


local forced_spell = false
local f_spell = 0
local f_unit = player
local f_icon = 0
 

local timerActive = false

local function startTimer(resetAfter, func)
    if not timerActive then
        timerActive = true
        C_Timer.After(resetAfter, function()
            func()
            timerActive = false;
        end)
    end
end

local function setunset(bool, spell, unit, id)
		forced_spell = bool
		f_spell = spell
		f_unit = unit
		f_icon = id
end

function DBM_Disease.rotation.pause(spell, unit)
    icon = DBM_Disease.FlexIcon(spell, 25,25)
	setunset(true, spell, unit, icon)

	startTimer(1.3, function()    
		setunset(false, nil, nil, nil)
	end )
end

function DBM_Disease.rotation.que(spell, unit)
	if spell == 6603 or spell == 467718 or spell == 75 then return end
	if spell == GetSpellInfo(6603) or spell == GetSpellInfo(467718) or spell == GetSpellInfo(75) then return end
	-- print("Before: ", forced_spell, f_spell, f_unit, f_icon)
	setunset(true, spell, unit, nil)
	-- print("After: ", forced_spell, f_spell, f_unit, f_icon)
	startTimer(1.3, function()    
		-- print("Before Reset: ", forced_spell, f_spell, f_unit, f_icon)
		setunset(false, nil, nil, nil)
		-- print("After Reset: ", forced_spell, f_spell, f_unit, f_icon)
	end )
end


local function resolve_me()
	if target and target.alive then
		return target.unitID
	end
	return player.unitID
end
setfenv(resolve_me, DBM_Disease.environment.env)

local function action_gcd(actionID)
	local _table = C_Spell.GetSpellCooldown(actionID)
	local start, duration = _table.startTime,  _table.duration
	local _table = C_Spell.GetSpellCooldown(actionID)
	if not _table then return 0 end
	local time, value = _table.startTime,  _table.duration

	local gcd_wait = start > 0 and (duration - (GetTime() - start)) or 0
	return gcd_wait
end

hooksecurefunc("UseAction", function(slot, checkFlags, onSelf)
	-- -- Exit if the action bar hook is disabled
	if not hookCast then
		return
	end
	if not UnitAffectingCombat('player') then
		return
	end

	-- Fetch action details from the slot
	local actionType, actionID = GetActionInfo(slot)

	if not actionType or not actionID then
		return
	end -- Exit for invalid actions

	-- Resolve the action name based on its type
	local actionName = (actionType == "spell" and GetSpellInfo(actionID))
		--or (actionType == "item" and GetItemInfo(actionID))
		--or (actionType == "macro" and GetMacroInfo(actionID))
	if not actionName then
		return
	end -- Exit if action name can't be resolved

	-- Resolve the appropriate target (player or current target)
	local resolvedTarget = resolve_me(); --(onSelf or not target) and player or target
	-- print(DBM_Disease.FlexIcon(actionID).. " attempted to que at " .. resolvedTarget)
	-- print('gcd(actionID): ', gcd(actionID))
	if action_gcd(actionID) == 0 then return end
	DBM_Disease.rotation.que(actionID, resolvedTarget)
end)

local stateval = DBM_Disease.settings.fetch('ssc') 
local lastGarbageCollection = 0

local function togglePlates()
	-- disable that = no aoe for you today.
	if GetCVar("nameplateShowEnemies") == '0' then
		C_CVar.SetCVar("nameplateShowEnemies", 1)
	end
end

local function IsAoEPending()
    return SpellIsTargeting()
end



local _lastcast;
-- Ура я выиграю в забеге на костылях!!
local function handle_combat_log(event, ...)
    local _, event, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID = ...;
    if not sourceGUID or sourceGUID == "" then return end
    if sourceGUID ~= UnitGUID("player") then return end
    if event == "SPELL_CAST_SUCCESS" then
		_lastcast = spellID;
    end
end
DBM_Disease.Listener:Add("track_lastcast", "COMBAT_LOG_EVENT_UNFILTERED", function(...) handle_combat_log("COMBAT_LOG_EVENT_UNFILTERED", CombatLogGetCurrentEventInfo()) end)

function DBM_Disease.rotation.tick(ticker)
	turbo = DBM_Disease.settings.fetch('_engine_turbo', false)
	hookCast = DBM_Disease.settings.fetch('_engine_hookCast', true)
	castclip = DBM_Disease.settings.fetch('_engine_castclip', 0.25)
	ticker._duration = DBM_Disease.settings.fetch('_engine_tickrate', 0.2)
	local _, _, lagHome, lagWorld = GetNetStats()
	local ownHaste = GetHaste()
	local elkek = (1.5/((100+ownHaste)/100))+lagWorld 

	local do_gcd = DBM_Disease.settings.fetch('_engine_gcd', true)
	local gcd_wait, start, duration = false
	
	if ticker._duration ~= last_duration then
		last_duration = ticker._duration
	end
	
	local toggled = DBM_Disease.settings.fetch_toggle('master_toggle', false)
	if not toggled then
		return
	end
	
	togglePlates();


-- print('forced_spell: ', forced_spell)

	if not forced_spell then
	else
		if _lastcast ~= f_spell then 
		-- print('Attempt to cast: ', f_spell, f_unit)

		CastSpellByID(f_spell, f_unit)

		if IsAoEPending() then
			if GetCVar("deselectOnClick") == '1' then
				C_CVar.SetCVar("deselectOnClick", 0) -- rip in combat t_t
			end
			CameraOrSelectOrMoveStart() 
			CameraOrSelectOrMoveStop()
		end
		end

		if _lastcast == f_spell then 
			C_CVar.SetCVar("deselectOnClick", 1) -- rip in combat t_t
			--TargetLastTarget();
			forced_spell = false
			return 
		end
		return
	end
	
	if forced_spell then 
		return 	
	end


	if gcd_spell and do_gcd then
	local _table = C_Spell.GetSpellCooldown(gcd_spell)
	local start, duration = _table.startTime,  _table.duration
	local _table = C_Spell.GetSpellCooldown(gcd_spell)
	if not _table then return 0 end
	local time, value = _table.startTime,  _table.duration

	gcd_wait = start > 0 and (duration - (GetTime() - start)) or 0
	end

	if DBM_Disease.rotation.active_rotation then
	if IsMounted() then return end

	if elkek ~= lastLag then
		lastLag = elkek
		DBM_Disease.rotation.timer.lag = elkek
	end

	if not turbo and (gcd_wait and gcd_wait > (elkek/1000 + castclip)) then 
		if DBM_Disease.rotation.active_rotation.gcd then
			return DBM_Disease.rotation.active_rotation.gcd()
		else
			return
		end
	end

	if UnitAffectingCombat('player') then
		items()
		DBM_Disease.rotation.active_rotation.combat()
	else
		DBM_Disease.rotation.active_rotation.resting()
	end
	end
end

DBM_Disease.on_ready(function()
  DBM_Disease.rotation.timer.ticker = C_Timer.NewAdvancedTicker(0.1, DBM_Disease.rotation.tick)
end)
