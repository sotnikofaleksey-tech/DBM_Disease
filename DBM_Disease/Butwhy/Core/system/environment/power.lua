local addon, DBM_Disease = ...

local power = { }

function power:base()
  return DBM_Disease.environment.conditions.powerType(self.unit)
end

function power:mana()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Mana, 'mana')
end

function power:rage()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Rage, 'rage')
end

function power:focus()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Focus, 'focus')
end

function power:energy()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Energy, 'energy')
end

function power:combopoints()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.ComboPoints, 'combopoints')
end

function power:runes()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Runes, 'runes')
end

function power:runicpower()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.RunicPower, 'runicpower')
end

function power:soulshards()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.SoulShards, 'soulshards')
end

function power:lunarpower()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.LunarPower, 'lunarpower')
end

function power:astral()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.LunarPower, 'astral')
end

function power:holypower()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.HolyPower, 'holypower')
end

function power:maelstrom()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Maelstrom, 'maelstrom')
end

function power:chi()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Chi, 'chi')
end

function power:insanity()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Insanity, 'insanity')
end

function power:arcanecharges()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.ArcaneCharges, 'arcanecharges')
end

function power:fury()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Fury, 'fury')
end

function power:pain()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Pain, 'pain')
end

function power:essence()
 return DBM_Disease.environment.conditions.powerType(self.unit, Enum.PowerType.Essence, 'Essence')
end

function DBM_Disease.environment.conditions.power(unit, called)
  return setmetatable({
    unit = unit,
    unitID = unit.unitID
  }, {
    __index = function(t, k)
      return power[k](t)
    end,
    __unm = function(t)
      return power['base'](t)
    end
  })
end
