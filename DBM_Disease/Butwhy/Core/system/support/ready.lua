local addon, DBM_Disease = ...

local ticker

ticker = C_Timer.NewTicker(0.1, function()
  if DBM_Disease.settings_ready then
    for _, callback in pairs(DBM_Disease.ready_callbacks) do
      callback()
    end
    ticker:Cancel()
  end
end)