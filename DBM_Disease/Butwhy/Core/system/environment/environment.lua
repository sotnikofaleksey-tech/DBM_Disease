local addon, DBM_Disease = ...


local GetBuffDataByIndex, GetDebuffDataByIndex = C_UnitAuras.GetBuffDataByIndex, C_UnitAuras.GetDebuffDataByIndex
local FindAura = AuraUtil.FindAura
local UnpackAuraData = AuraUtil.UnpackAuraData

UnitBuff = function( unit, index, filter )
    return UnpackAuraData( GetBuffDataByIndex( unit, index, filter ) )
end

UnitDebuff = function( unit, index, filter )
    return UnpackAuraData( GetDebuffDataByIndex( unit, index, filter ) )
end


DBM_Disease.environment = {
  conditions = { },
  hooks = { },
  unit_cache = { },
  group_cache = nil,
  hook_cache = { }
}

local env = { }

DBM_Disease.environment.env = setmetatable(env, {
  __index = function(_env, called)
    local ds = debugstack(2, 1, 0)
    local file, line = string.match(ds, '^.-\(%a-%.lua):(%d+):.+$')
    DBM_Disease.console.file = file
    DBM_Disease.console.line = line
    if DBM_Disease.environment.logical.validate(called) then
      if not DBM_Disease.environment.unit_cache[called] then
        DBM_Disease.environment.unit_cache[called] = DBM_Disease.environment.conditions.unit(called)
      end
      return DBM_Disease.environment.unit_cache[called]
    elseif DBM_Disease.environment.virtual.validate(called) then
      local resolved, virtual_type = DBM_Disease.environment.virtual.resolve(called)
      if virtual_type == 'unit' then
        if not DBM_Disease.environment.unit_cache[resolved] then
          DBM_Disease.environment.unit_cache[resolved] = DBM_Disease.environment.conditions.unit(resolved)
        end
        return DBM_Disease.environment.unit_cache[resolved]
      elseif virtual_type == 'group' then
        if not DBM_Disease.environment.group_cache then
          DBM_Disease.environment.group_cache = DBM_Disease.environment.conditions.group()
        end
        return DBM_Disease.environment.group_cache
      end
    elseif DBM_Disease.environment.hooks[called] then
      if not DBM_Disease.environment.hook_cache[called] then
        DBM_Disease.environment.hook_cache[called] = DBM_Disease.environment.hooks[called]
      end
      return DBM_Disease.environment.hook_cache[called]
    end
    return _G[called]
  end
})

function DBM_Disease.environment.hook(func)
  setfenv(func, DBM_Disease.environment.env)
end

-- function DBM_Disease.environment.iterator(raw)
  -- local members = GetNumGroupMembers()
  -- local group_type = IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
  -- local index = 0
  -- local returned_solo = false
  -- return function()
    -- local called
    -- if group_type == 'solo' and not returned_solo then
      -- returned_solo = true
      -- called = 'player'
    -- elseif group_type ~= 'solo' then
      -- if index <= members then
        -- index = index + 1
        -- if group_type == 'party' and index == members then
          -- called = 'player'
        -- else
          -- called = group_type .. index
        -- end
      -- end
    -- end
    -- if called then
      -- if raw then
        -- return called
      -- end
      -- if not DBM_Disease.environment.unit_cache[called] then
        -- DBM_Disease.environment.unit_cache[called] = DBM_Disease.environment.conditions.unit(called)
      -- end
      -- return DBM_Disease.environment.unit_cache[called]
    -- end
  -- end
-- end

-- Итератор для членов группы
-- function DBM_Disease.environment.iterator(raw)
  -- local group_type = DBM_Disease.environment.group_type_cache
  -- local members = DBM_Disease.environment.members_cache or 1
  -- local index = 0
  -- local returned_solo = false

  -- -- Если группа обновилась, пересчитать тип и размер группы
  -- if not group_type or not members then
    -- members = GetNumGroupMembers()
    -- group_type = IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
    -- DBM_Disease.environment.group_type_cache = group_type
    -- DBM_Disease.environment.members_cache = members
  -- end

  -- return function()
    -- local called
    -- if group_type == 'solo' and not returned_solo then
      -- returned_solo = true
      -- called = 'player'
    -- elseif group_type ~= 'solo' then
      -- index = index + 1
      -- if index <= members then
        -- if group_type == 'party' and index == members then
          -- called = 'player'
        -- else
          -- called = group_type .. index
        -- end
      -- end
    -- end
    -- if called then
      -- if raw then
        -- return called
      -- end
      -- DBM_Disease.environment.unit_cache[called] = DBM_Disease.environment.unit_cache[called] 
        -- or DBM_Disease.environment.conditions.unit(called)
      -- return DBM_Disease.environment.unit_cache[called]
    -- end
  -- end
-- end

-- -- Функция для обновления кэша группы
-- local function update_group_cache()
  -- DBM_Disease.environment.group_type_cache = nil
  -- DBM_Disease.environment.members_cache = nil
  -- DBM_Disease.environment.unit_cache = {}
-- end

-- -- Регистрация событий через DBM_Disease.Listener
-- DBM_Disease.Listener:Add("roster", "GROUP_ROSTER_UPDATE", update_group_cache)
-- DBM_Disease.Listener:Add("the_world", "PLAYER_ENTERING_WORLD", update_group_cache)



-- Кэш группы
local group_cache = {}

-- Обновление кэша группы
local function refresh_group_cache()
		-- --print('-------')
    -- local start_time = debugprofilestop()
    -- --print('1. '..start_time)

  local group_type = IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
  local members = GetNumGroupMembers()
  group_cache = {} -- Очистить старый кэш

  if group_type == 'solo' then
    table.insert(group_cache, 'player')
  else
    for i = 1, members do
      local unit = (group_type == 'party' and i == members) and 'player' or (group_type .. i)
      table.insert(group_cache, unit)
    end
  end
      -- local end_time = debugprofilestop()
	-- --print('2. '..end_time)
    -- local diff = end_time - start_time
	-- --print(string.format('Lowest detection Difference: %.1f ms', diff))
    -- --print('-------')
end

-- Итератор по кэшу группы
function DBM_Disease.environment.iterator(raw)
  local index = 0
  return function()
    index = index + 1
    local unitID = group_cache[index]
    if not unitID then return nil end

    if raw then
      return unitID
    end

    DBM_Disease.environment.unit_cache[unitID] = DBM_Disease.environment.unit_cache[unitID] 
      or DBM_Disease.environment.conditions.unit(unitID)
    return DBM_Disease.environment.unit_cache[unitID]
  end
end

-- Регистрация обновления кэша при событиях
DBM_Disease.Listener:Add("rost", "GROUP_ROSTER_UPDATE", refresh_group_cache)
DBM_Disease.Listener:Add("pew","PLAYER_ENTERING_WORLD", refresh_group_cache)

-- Первоначальная инициализация кэша
refresh_group_cache()





DBM_Disease.environment.hooks.each_member = DBM_Disease.environment.iterator

DBM_Disease.environment.unit_buff = function(target, spell, owner)
  local buff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 40 and go do
    i = i + 1
    buff, _, count, _, duration, expires, caster, stealable, _, spellID = _G['UnitBuff'](target, i)
    if not owner then
      if ((tonumber(spell) and spellID == tonumber(spell)) or buff == spell) and caster == "player" then go = false end
    elseif owner == "any" then
      if ((tonumber(spell) and spellID == tonumber(spell)) or buff == spell) then go = false end
    end
  end
  return buff, count, duration, expires, caster, stealable, spellID
end

DBM_Disease.environment.unit_debuff = function(target, spell, owner)
  local debuff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 40 and go do
    i = i + 1
    debuff, _, count, _, duration, expires, caster, _, _, spellID = _G['UnitDebuff'](target, i)
    if not owner then
      if ((tonumber(spell) and spellID == tonumber(spell)) or debuff == spell) and caster == "player" then go = false end
    elseif owner == "any" then
      if ((tonumber(spell) and spellID == tonumber(spell)) or debuff == spell) then go = false end
    end
  end
  return debuff, count, duration, expires, caster, spellID
end

DBM_Disease.environment.unit_reverse_debuff = function(target, candidates)
  local debuff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 40 and go do
    i = i + 1
    debuff, _, count, _, duration, expires, caster, _, _, spellID = _G['UnitDebuff'](target, i)
    if candidates[spellID] then go = false end
  end
  return debuff, count, duration, expires, caster, candidates[spellID]
end
