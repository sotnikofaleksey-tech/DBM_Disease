local addon, DBM_Disease = ...

DBM_Disease.rotation = {
  classes = {
    hekili = 1
  },
  rotation_store = { },
  active_rotation = false
}

function DBM_Disease.rotation.register(config)
  if config.gcd then
    setfenv(config.gcd, DBM_Disease.environment.env)
  end
  if config.combat then
    setfenv(config.combat, DBM_Disease.environment.env)	
  end
  if config.resting then
    setfenv(config.resting, DBM_Disease.environment.env)
  end
  DBM_Disease.rotation.rotation_store[config.name] = config
end

function DBM_Disease.rotation.load(name)
  local rotation
  for _, rot in pairs(DBM_Disease.rotation.rotation_store) do
    if rot.name == name then
      rotation = rot
    end
  end

  if rotation then
    DBM_Disease.settings.store('active_rotation', name)
    DBM_Disease.rotation.active_rotation = rotation
    DBM_Disease.interface.buttons.reset()
    if rotation.interface then
      rotation.interface(rotation)
    end
    if DBM_Disease.settings.fetch("netload_rotation_release", nil) then
      DBM_Disease.log('Loaded rotation: ' .. name .. ' (network)')
    else
      DBM_Disease.log('Loaded rotation: ' .. name)
    end
   
  else
    DBM_Disease.error('Unable to load rotation: ' .. name)
  end
end


local loading_wait = false

local timer
local function init()
  if not loading_wait then
    timer = C_Timer.NewTicker(0.3, function()
      if DBM_Disease.protected then
        local active_rotation = DBM_Disease.settings.fetch('active_rotation', false)
        local netload_rotation_release = DBM_Disease.settings.fetch('netload_rotation_release', false)
        if active_rotation then
			DBM_Disease.rotation.load(active_rotation)
        else
			DBM_Disease.rotation.load("Hload")
        end
        loading_wait = false
        timer:Cancel()
      end
    end)
  end
end

local f = CreateFrame("Frame")
local login = true
 
local function onevent(self, event, arg1, ...)
    if(login and ((event == "PLAYER_ENTERING_WORLD"))) then
        login = nil
		init()
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end
 
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", onevent)