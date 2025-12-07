local addon, DBM_Disease = ...

DBM_Disease.event = {
  events = { },
  callbacks = { }
}

local frame = CreateFrame('frame')

function DBM_Disease.event.register(event, callback)
  if not DBM_Disease.event.events[event] then
    frame:RegisterEvent(event)
    DBM_Disease.event.events[event] = true
    DBM_Disease.event.callbacks[event] = { }
  end
  table.insert(DBM_Disease.event.callbacks[event], callback)
end

frame:SetScript('OnEvent', function(self, event, ...)
  if DBM_Disease.event.callbacks[event] then
    for key, callback in ipairs(DBM_Disease.event.callbacks[event]) do
      callback(...)
    end
  end
end)
