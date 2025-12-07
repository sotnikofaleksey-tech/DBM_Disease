local addon, DBM_Disease = ...
local onEvent = _G.onEvent
local CreateFrame = _G.CreateFrame

DBM_Disease.Listener = {}
local listeners = {}

local DBM_Disease_listener = CreateFrame('Frame')
DBM_Disease_listener:SetScript('OnEvent', function(_, event, ...)
    if not listeners[event] then return end
    for _, callback in pairs(listeners[event]) do
        callback(...)
    end
end)

function DBM_Disease.Listener:Add(name, event, callback)
    if not listeners[event] then
        DBM_Disease_listener:RegisterEvent(event)
        listeners[event] = {}
    end
    listeners[event][name] = callback
end

function DBM_Disease.Listener:Remove(name, event)
    if listeners[event] then
        listeners[event][name] = nil
    end
end

function DBM_Disease.Listener:Trigger(event, ...)
    onEvent(nil, event, ...)
end
