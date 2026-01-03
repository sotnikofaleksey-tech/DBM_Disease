-- DBM_Disease - Pure Core Module
-- Only class detection and module loading
local addonName = "DBM_Disease"

-- Debug function
local function Debug(msg)
    local hour, minute = GetGameTime()
    local timestamp = string.format("%02d:%02d", hour, minute)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00DBM_Disease ["..timestamp.."]: |r"..msg)
end

-- Main addon table
DBM_Disease = DBM_Disease or {}
DBM_Disease.Debug = Debug
DBM_Disease.Modules = {}
DBM_Disease.LoadedModule = nil

-- Module registry
function DBM_Disease.RegisterModule(class, moduleTable)
    Debug("Registering module for class: "..class)
    DBM_Disease.Modules[class] = moduleTable
end

-- Module loader
function DBM_Disease.LoadModule(class)
    Debug("Attempting to load module for class: "..class)
    
    if not DBM_Disease.Modules[class] then
        Debug("|cFFFF0000No module registered for class: "..class.."|r")
        return false
    end
    
    local module = DBM_Disease.Modules[class]
    
    if not module.Initialize then
        Debug("|cFFFF0000Module for "..class.." has no Initialize function|r")
        return false
    end
    
    -- Load the module
    local success, err = pcall(function()
        module.Initialize()
    end)
    
    if success then
        Debug("Module for "..class.." loaded successfully")
        DBM_Disease.LoadedModule = module
        return true
    else
        Debug("|cFFFF0000Error loading module for "..class..": "..tostring(err).."|r")
        return false
    end
end

-- Core initialization
local function InitializeCore()
    Debug("=== DBM_Disease Core Initializing ===")
    
    -- Get player class
    local _, playerClass = UnitClass("player")
    Debug("Player class detected: "..playerClass)
    
    -- Load appropriate module
    if DBM_Disease.Modules[playerClass] then
        DBM_Disease.LoadModule(playerClass)
    else
        Debug("|cFFFF0000No module available for class: "..playerClass.."|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000DBM_Disease: No rotation module for "..playerClass.."|r")
    end
    
    Debug("=== DBM_Disease Core Initialization Complete ===")
end

-- Event handler
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        Debug("PLAYER_LOGIN event received")
        InitializeCore()
    end
end)

-- Core slash commands (only for core functionality)
SLASH_DBMDISEASE1 = "/dbm"
SlashCmdList["DBMDISEASE"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "debug" then
        DBM_Disease.debugMode = not DBM_Disease.debugMode
        if DBM_Disease.debugMode then
            Debug("Debug mode ENABLED")
        else
            Debug("Debug mode DISABLED")
        end
    elseif cmd == "status" then
        local _, playerClass = UnitClass("player")
        Debug("=== DBM_Disease Status ===")
        Debug("Class: "..playerClass)
        Debug("Module loaded: "..tostring(DBM_Disease.LoadedModule and true or false))
        Debug("Registered modules: "..table.concat({}, ", "))
        for class, _ in pairs(DBM_Disease.Modules) do
            Debug("  - "..class)
        end
    elseif cmd == "reload" then
        Debug("Reloading module...")
        local _, playerClass = UnitClass("player")
        DBM_Disease.LoadModule(playerClass)
    elseif cmd == "help" or cmd == "" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00DBM_Disease Core Commands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/dbm debug|r - Toggle debug mode")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/dbm status|r - Show addon status")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/dbm reload|r - Reload current module")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/dbm help|r - Show this help")
    else
        Debug("Unknown command: "..cmd)
        Debug("Type /dbm help for commands")
    end
end

Debug("DBM_Disease Core loaded - waiting for PLAYER_LOGIN")