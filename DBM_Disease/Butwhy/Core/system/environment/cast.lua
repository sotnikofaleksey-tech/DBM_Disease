local addon, DBM_Disease = ...
local lastcasted_target = nil

DBM_Disease._A = {}
local _A = DBM_Disease._A
setmetatable(_A, {
    __call = function(t, func, ...)
        if not func then return end
        if not issecure() then return end

        local args = { ... }
        local ok, err = pcall(function()
            if #args > 0 then
                func(unpack(args))
            else
                func()
            end
        end)
        if not ok then
            print("Ошибка функции:", err)
        end
    end,
    __index = function(t, k)
        local v = _G[k]
        if v == nil then return nil end
        
        if type(v) == "function" then
            return function(...)
                return _A(v, ...)
            end
        elseif type(v) == "table" then
            local proxy = {}
            setmetatable(proxy, {
                __index = function(t2, k2)
                    local v2 = v[k2]
                    if type(v2) == "function" then
                        return function(...)
                            return _A(v2, ...)
                        end
                    end
                    return v2
                end
            })
            return proxy
        end
        return v
    end
})

function _CastSpellByName(spell, target)
    target = target or "target"
    if not spell then
        DBM_Disease.console.debug(2, "cast", "red", "Заклинание " .. tostring(spell) .. " не найдено")
        return
    end
    _A.CastSpellByName(spell, target)
    lastcasted_target = target
    DBM_Disease.console.debug(2, "cast", "red", spell .. " на " .. target)
end

function _CastGroundSpellByName(spell, target)
    target = target or "target"

    if type(spell) == "table" then
        local _, name = unpack(spell)
        spell = name
    end
    if not spell then
        DBM_Disease.console.debug(2, "cast", "red", "Заклинание " .. tostring(spell) .. " не найдено")
        return
    end
    _A.C_Macro.RunMacroText("/cast [@cursor] " .. spell, 255)
    lastcasted_target = target
    DBM_Disease.console.debug(2, "cast", "red", spell .. " на " .. target)
end

function _CastSpellByID(spell, target)
    target = target or "target"
    if not spell then
        DBM_Disease.console.debug(2, "cast", "red", "Заклинание " .. tostring(spell) .. " не найдено")
        return
    end
    _A.CastSpellByID(spell, target)
    lastcasted_target = target
    DBM_Disease.console.debug(2, "cast", "red", spell .. " на " .. target)
end

function _CastGroundSpellByID(spell, target)
    return _CastSpellByID(spell, target)
end

function _SpellStopCasting()
    _A.SpellStopCasting()
end

local function auto_attack()
    if C_Spell.IsCurrentSpell(6603) then return end
    _A.CastSpellByID(6603)
    DBM_Disease.console.debug(2, "cast", "red", "Авто Атака")
end

local function auto_shot()
    if C_Spell.IsCurrentSpell(75) then return end
    _A.CastSpellByID(75)
    DBM_Disease.console.debug(2, "cast", "red", "Авто Атака")
end

function RunMacroText(text)
    if not text then
        DBM_Disease.console.debug(2, "macro", "red", "Текст макроса не указан")
        return
    end
    _A.C_Macro.RunMacroText(text, 255)
    DBM_Disease.console.debug(2, "macro", "red", text)
end

DBM_Disease.tmp.store("lastcast", spell)

local function is_unlocked()
    if issecure() then
        DBM_Disease.console.debug(3, "check", "red", "Проверка разблокировки: успешно")
        return true
    else
        DBM_Disease.console.debug(3, "check", "red", "Окружение не безопасно, проверка разблокировки не выполнена")
        return false
    end
end

local turbo = false

function DBM_Disease.environment.hooks.cast(spell, target)
    turbo = DBM_Disease.settings.fetch("_engine_turbo", false)
    if not DBM_Disease.protected then
        return -- DBM_Disease.glow.trigger(spell)
    end

    if type(target) == "table" then
        target = target.unitID
    end

    if turbo or not UnitCastingInfo("player") then
        if target == "ground" then
            if tonumber(spell) then
                local spellName = C_Spell.GetSpellName(spell)
                _CastGroundSpellByName(spellName, target)
            else
                _CastGroundSpellByName(spell, target)
            end
        else
            if tonumber(spell) then
                local spellName = C_Spell.GetSpellName(spell)
                _CastSpellByName(spellName, target)
            else
                _CastSpellByName(spell, target)
            end
        end
    end
end

function DBM_Disease.environment.hooks.auto_attack()
    auto_attack()
end

function DBM_Disease.environment.hooks.auto_shot()
    auto_shot()
end

function DBM_Disease.environment.hooks.stopcast()
    _SpellStopCasting()
end

function DBM_Disease.environment.hooks.macro(text)
    RunMacroText(text)
end

function DBM_Disease.environment.virtual.targets.lastcasted_target()
    return lastcasted_target
end

local timer
timer =
  C_Timer.NewTicker(
  0.5,
  function()
      if not DBM_Disease.adv_protected and is_unlocked() then
		stateval = DBM_Disease.settings.fetch('ssc')
		if stateval == 2 then 
			DBM_Disease.log("LUA Unlocker Found! Enabled!")
		end
        DBM_Disease.protected = true
        DBM_Disease.protect_version = "777"
        DBM_Disease.adv_protected = false
        DBM_Disease.luabox = false
        timer:Cancel()
      end
  end
)

DBM_Disease.event.register("UNIT_SPELLCAST_SUCCEEDED", function(...)
    local unitID, lineID, spellID = ...
    local spell = C_Spell.GetSpellInfo(spellID)
    if unitID == "player" then
        DBM_Disease.tmp.store("lastcast", spellID)
    end
end)
