local addon, DBM_Disease = ...
if (GetLocale() == "ruRU") then
 L_Build = "Билд:"
 L_CreateProfile = "Создаю новый профиль настроек."
 L_LoadedCFG = "Настройки загружены."
else
 L_Build = "Build: "
 L_CreateProfile = "Creating settings profile."
 L_LoadedCFG = "Settings loaded."
end
    if DBM_Disease_storage == nil then 
      DBM_Disease_storage = { }
    end
local frame = CreateFrame('frame')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript('OnEvent', function(self, event, arg1)
  if event == 'ADDON_LOADED' and arg1 == addon then
    if DBM_Disease_storage == nil then
      DBM_Disease_storage = { }
	  state = 0
	  DBM_Disease.settings.store('ssc', state)
	  stateval = DBM_Disease.settings.fetch('ssc') 
   if stateval == 2 then DBM_Disease.log(L_Build .. DBM_Disease.version) end
   if stateval == 2 then DBM_Disease.log(L_CreateProfile) end
    else
  if stateval == 2 then DBM_Disease.log(L_LoadedCFG) end
    end
    DBM_Disease.settings_ready = true
  end
end)

DBM_Disease.settings = { }

function DBM_Disease.settings.store(key, value)
  DBM_Disease_storage[key] = value
  return true
end

function DBM_Disease.settings.fetch(key, default)
  local value = DBM_Disease_storage[key]
  return value == nil and default or value
end

function DBM_Disease.settings.store_toggle(key, value)
  local active_rotation = DBM_Disease.settings.fetch('active_rotation', false)
  if not active_rotation then return end
  local full_key
  if DBM_Disease.rotation.active_rotation then
    full_key = active_rotation .. '_toggle_' .. key
  else
    full_key = 'toggle_' .. key
  end
  DBM_Disease_storage[full_key] = value
  DBM_Disease.console.debug(5, 'settings', 'purple', string.format(
    '%s <= %s', full_key, tostring(value)
  ))
  return true
end

function DBM_Disease.settings.fetch_toggle(key, default)
  local active_rotation = DBM_Disease.settings.fetch('active_rotation', false)
  if not active_rotation then return end
  local full_key
  if DBM_Disease.rotation.active_rotation then
    full_key = active_rotation .. '_toggle_' .. key
  else
    full_key = 'toggle_' .. key
  end
  if not string.find(full_key, 'master_toggle') then
    DBM_Disease.console.debug(5, 'settings', 'purple', string.format(
      '%s => %s', full_key, tostring(default)
    ))
  end
  return  DBM_Disease_storage[full_key] or default
end

DBM_Disease.tmp = {
  cache = { }
}

function DBM_Disease.tmp.store(key, value)
  DBM_Disease.tmp.cache[key] = value
  return true
end

function DBM_Disease.tmp.fetch(key, default)
  return DBM_Disease.tmp.cache[key] or default
end

DBM_Disease.on_ready(function()
  DBM_Disease.environment.hooks.toggle = function(key, default)
    return DBM_Disease.settings.fetch_toggle(key, default)
  end
  DBM_Disease.environment.hooks.storage = function(key, default)
    return DBM_Disease.settings.fetch(key, default)
  end
end)
