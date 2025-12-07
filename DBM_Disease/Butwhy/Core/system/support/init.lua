local addon, DBM_Disease = ...

DBM_Disease.name = 'DBM_Disease'
DBM_Disease.version = '0'
DBM_Disease.color = '727bad'
DBM_Disease.color2 = '72ad98'
DBM_Disease.color3 = '96ad72'
DBM_Disease.ready = false
DBM_Disease.settings_ready = false
DBM_Disease.ready_callbacks = { }
DBM_Disease.protected = false
DBM_Disease.adv_protected = false

function DBM_Disease.on_ready(callback)
  DBM_Disease.ready_callbacks[callback] = callback
end
