local addon, DBM_Disease = ...

local UnitBuff = DBM_Disease.environment.unit_buff

local buff = { }

function buff:exists()
  local buff, count, duration, expires, caster, _, id   = UnitBuff(self.unitID, self.spell, 'any')
  if id == self.spell and (not self.casterCheck and (caster == 'player' or caster == 'pet')) then
    return true
  end
  return false
end

function buff:down()
  return not self.exists
end

function buff:up()
  return self.exists
end

function buff:any()
  local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
  if buff then
    return true
  end
  return false
end

function buff:count()
  local buff, count, duration, expires, caster, _, id  = UnitBuff(self.unitID, self.spell, 'any')
  if id == self.spell and (not self.casterCheck and (caster == 'player' or caster == 'pet')) then
    return count
  end
  return 0
end

function buff:remains()
  local buff, count, duration, expires, caster, _, id = UnitBuff(self.unitID, self.spell, 'any')
  if id == self.spell and (not self.casterCheck and (caster == 'player' or caster == 'pet')) then
    return expires - GetTime()
  end
  return 0
end

function buff:duration()
  local buff, count, duration, expires, caster = UnitBuff(self.unitID, self.spell, 'any')
  if buff and (not self.casterCheck and (caster == 'player' or caster == 'pet')) then
    return duration
  end
  return 0
end

function buff:stealable()
  local buff, count, duration, expires, caster, stealable = UnitBuff(self.unitID, self.spell, 'any')
  if stealable then
    return true
  end
  return false
end
--
function DBM_Disease.environment.conditions.buff(unit)
  return setmetatable({
    unitID = unit.unitID
  }, {
    __index = function(self, func, bool)
      local result = buff[func](self)
      DBM_Disease.console.debug(4, 'buff', 'green', self.unitID .. '.buff(' .. tostring(self.spell) .. ').' .. func .. ' = ' .. DBM_Disease.format(result))
      return result
    end,
    __call = function(self, arg)
	  id = C_Spell.GetSpellInfo(arg).spellID
      if type(arg) == 'table' then
        self.spell = id
      else
        self.spell = arg
      end
	  if type(bool) == 'boolean' then
		self.casterCheck = bool or false
	  else
		self.casterCheck = false -- uh, retard moment (._.)
	  end
      return self
    end,
    __unm = function(t)
      local result = buff['exists'](t)
      DBM_Disease.console.debug(4, 'buff', 'green', t.unitID .. '.buff(' .. tostring(t.spell) .. ').exists = ' .. DBM_Disease.format(result))
      return result
    end
  })
end
