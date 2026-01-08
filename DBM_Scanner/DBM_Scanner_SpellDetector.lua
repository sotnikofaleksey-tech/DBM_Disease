-- ==============================================
-- DBM_Scanner_SpellDetector - Детектор ID заклинаний
-- ==============================================
local addonName = "DBM_Scanner_SpellDetector"

DBM_Scanner_SpellDetector = DBM_Scanner_SpellDetector or {}
local DSD = DBM_Scanner_SpellDetector

-- Инициализация
function DSD:Initialize()
    self:Print("Детектор ID заклинаний загружен!")
    self:Print("Используйте /detect для помощи")
end

DSD.combatFrame = CreateFrame("Frame")
DSD.combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

DSD.combatFrame:SetScript("OnEvent", function(self, event, ...)
    local timestamp, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = ...
    
    if sourceGUID == UnitGUID("player") then
        if subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_DAMAGE" or subEvent == "SPELL_HEAL" then
            if spellID and spellID > 0 then
                DSD:LogSpellFromCombat(spellID, spellName, subEvent)
            end
        end
    end
end)

function DSD:LogSpellFromCombat(spellID, spellName, eventType)
    if not self.isLogging then return end
    
    local name, _, _, castTime, _, _, actualID = GetSpellInfo(spellID)
    local finalName = name or spellName or "Unknown"
    local finalID = actualID or spellID
    
    -- Сохраняем
    local key = finalName.."_"..finalID
    if not self.detectedSpells[key] then
        self.detectedSpells[key] = {
            id = finalID,
            name = finalName,
            castTime = castTime or 0,
            event = eventType,
            count = 1,
            lastSeen = GetTime()
        }
        self:Print("✓ Обнаружено: "..finalName.." (ID: "..finalID..") через "..eventType)
    else
        self.detectedSpells[key].count = self.detectedSpells[key].count + 1
    end
end

-- Метод 1: Поиск ID по tooltip (самый надежный для кастомных серверов)
function DSD:DetectByTooltip()
    self:Print("|cFFFF0000=== ДЕТЕКЦИЯ ПО TOOLTIP ===|r")
    self:Print("Наведите курсор на заклинание и введите /detect tooltip")
end

function DSD:GetSpellFromTooltip()
    local frame = GetMouseFocus()
    if not frame then
        self:Print("Наведите курсор на заклинание!")
        return
    end
    
    -- Пробуем получить информацию из тултипа
    local tooltip = GameTooltip
    if tooltip:IsVisible() then
        local spellName = tooltip:GetSpell()
        if spellName then
            self:Print("Найдено в тултипе: "..spellName)
            self:FindSpellID(spellName)
        else
            -- Альтернативный метод: читаем текст тултипа
            local text = _G["GameTooltipTextLeft1"]:GetText()
            if text then
                self:Print("Текст тултипа: "..text)
                self:FindSpellID(text)
            end
        end
    else
        self:Print("Тултип не виден. Наведите курсор на заклинание.")
    end
end

-- Метод 2: Поиск по действиям на панели
function DSD:DetectActionBar()
    self:Print("|cFFFF0000=== СКАНИРОВАНИЕ ПАНЕЛИ ДЕЙСТВИЙ ===|r")
    
    local foundSpells = {}
    
    -- Проверяем все слоты действия (1-120)
    for slot = 1, 120 do
        local actionType, id, subType = GetActionInfo(slot)
        
        if actionType == "spell" and id then
            local name, _, _, castTime = GetSpellInfo(id)
            if name then
                table.insert(foundSpells, {
                    slot = slot,
                    id = id,
                    name = name,
                    castTime = castTime
                })
                self:Print(string.format("Слот %d: %s (ID: %d)", slot, name, id))
            end
        end
    end
    
    self:Print("Найдено заклинаний на панели: "..#foundSpells)
    return foundSpells
end

-- Метод 3: Поиск по буффам/дебаффам
function DSD:DetectAuras()
    self:Print("|cFFFF0000=== СКАНИРОВАНИЕ АУР ===|r")
    
    -- Баффы на игроке
    self:Print("Баффы на игроке:")
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if not name then break end
        self:Print(string.format("  %d. %s (ID: %d)", i, name, spellId))
    end
    
    -- Дебаффы на цели
    if UnitExists("target") then
        self:Print("Дебаффы на цели:")
        for i = 1, 40 do
            local name, _, _, _, _, _, _, _, _, spellId = UnitDebuff("target", i)
            if not name then break end
            self:Print(string.format("  %d. %s (ID: %d)", i, name, spellId))
        end
    end
end

-- Метод 4: Лог кастов (самый эффективный)
function DSD:StartCastLogger()
    self:Print("|cFFFF0000=== ЛОГГЕР КАСТОВ ВКЛЮЧЕН ===|r")
    self:Print("Все кастуемые заклинания будут записаны")
    self:Print("Используйте заклинания на манекене")
    self:Print("Введите /detect stop чтобы остановить")
    
    self.castLogger = true
    self.castLog = {}
    
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    frame:SetScript("OnEvent", function(self, event, unit, _, spellID)
        if event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and DSD.castLogger then
            local name, _, _, castTime = GetSpellInfo(spellID)
            if name then
                local logEntry = {
                    id = spellID,
                    name = name,
                    castTime = castTime,
                    time = GetTime()
                }
                
                table.insert(DSD.castLog, logEntry)
                DSD:Print(string.format("Записано: %s (ID: %d)", name, spellID))
                
                -- Автоматически добавляем в сканер если он есть
                if DBM_Scanner_Spells and DBM_Scanner_Spells.AddSpellManual then
                    DBM_Scanner_Spells:AddSpellManual(spellID, name)
                end
            end
        end
    end)
end

function DSD:StopCastLogger()
    self.castLogger = false
    self:Print("|cFF00FF00Логгер остановлен|r")
    self:Print("Записано заклинаний: "..#(self.castLog or {}))
    
    if self.castLog and #self.castLog > 0 then
        self:Print("=== ЗАПИСАННЫЕ ЗАКЛИНАНИЯ ===")
        for i, entry in ipairs(self.castLog) do
            self:Print(string.format("%d. %s (ID: %d)", i, entry.name, entry.id))
        end
    end
end

-- Метод 5: Поиск ID по имени (расширенный)
function DSD:FindSpellID(spellName)
    if not spellName then return end
    
    self:Print("Поиск ID для: "..spellName)
    
    local foundIDs = {}
    
    -- Широкий диапазон поиска
    for id = 1, 300000 do
        local name = GetSpellInfo(id)
        if name and string.lower(name) == string.lower(spellName) then
            table.insert(foundIDs, id)
            
            -- Проверяем доступно ли заклинание
            local isKnown = IsSpellKnown(id) or IsPlayerSpell(id)
            local status = isKnown and "|cFF00FF00ДОСТУПНО|r" or "|cFFFF0000недоступно|r"
            
            self:Print("  Найден ID: "..id.." - "..status)
            
            -- Останавливаемся после 5 найденных
            if #foundIDs >= 5 then break end
        end
        
        -- Прогресс
        if id % 50000 == 0 then
            self:Print("Проверено "..id.." ID...")
        end
    end
    
    if #foundIDs == 0 then
        self:Print("|cFFFF0000ID не найден|r")
    end
    
    return foundIDs[1]
end

-- Метод 6: Экспорт всех известных заклинаний в файл
function DSD:ExportAllSpells()
    self:Print("|cFFFF0000Экспорт всех заклинаний...|r")
    
    local allSpells = {}
    
    -- Собираем из книги
    for i = 1, 500 do
        local name = GetSpellBookItemName(i, BOOKTYPE_SPELL)
        if not name then break end
        
        local slotType, id = GetSpellBookItemInfo(i, BOOKTYPE_SPELL)
        if slotType == "SPELL" and id then
            table.insert(allSpells, {id = id, name = name, source = "book"})
        end
    end
    
    -- Собираем с панели действий
    for slot = 1, 120 do
        local actionType, id = GetActionInfo(slot)
        if actionType == "spell" and id then
            local name = GetSpellInfo(id)
            if name then
                table.insert(allSpells, {id = id, name = name, source = "actionbar", slot = slot})
            end
        end
    end
    
    -- Убираем дубликаты
    local uniqueSpells = {}
    local seen = {}
    
    for _, spell in ipairs(allSpells) do
        local key = spell.name.."_"..spell.id
        if not seen[key] then
            seen[key] = true
            table.insert(uniqueSpells, spell)
        end
    end
    
    -- Вывод
    self:Print("=== ВСЕ УНИКАЛЬНЫЕ ЗАКЛИНАНИЯ ("..#uniqueSpells..") ===")
    
    table.sort(uniqueSpells, function(a, b) return a.name < b.name end)
    
    for i, spell in ipairs(uniqueSpells) do
        local sourceText = spell.source == "book" and "книга" or "панель"
        local slotText = spell.slot and " слот "..spell.slot or ""
        self:Print(string.format("%3d. %-25s |cFFFFFF00ID: %d|r [%s%s]", 
            i, spell.name, spell.id, sourceText, slotText))
    end
    
    -- Экспорт для копирования
    self:Print("=== ДЛЯ КОПИРОВАНИЯ В DBM_Scanner_Spells.lua ===")
    self:Print("local detectedSpells = {")
    
    for _, spell in ipairs(uniqueSpells) do
        self:Print(string.format('    {id = %d, name = "%s"},', spell.id, spell.name))
    end
    
    self:Print("}")
end

-- Команды
SLASH_DETECT1 = "/detect"
SLASH_DETECT2 = "/findspell"

local function HandleCommand(msg)
    msg = msg or ""
    local args = {}
    
    for arg in string.gmatch(msg, "%S+") do
        table.insert(args, arg)
    end
    
    local cmd = args[1] or ""
    cmd = string.lower(cmd)
    
    if cmd == "" or cmd == "help" then
        DSD:Print("=== КОМАНДЫ ДЕТЕКТОРА ===")
        DSD:Print("|cFFFFFF00/detect tooltip|r - Определить заклинание под курсором")
        DSD:Print("|cFFFFFF00/detect actionbar|r - Сканировать панель действий")
        DSD:Print("|cFFFFFF00/detect auras|r - Сканировать ауры")
        DSD:Print("|cFFFFFF00/detect start|r - Запустить логгер кастов")
        DSD:Print("|cFFFFFF00/detect stop|r - Остановить логгер")
        DSD:Print("|cFFFFFF00/detect export|r - Экспорт всех заклинаний")
        DSD:Print("|cFFFFFF00/detect find [название]|r - Найти ID по имени")
        DSD:Print("|cFFFFFF00/detect help|r - Эта справка")
        
    elseif cmd == "tooltip" then
        DSD:GetSpellFromTooltip()
        
    elseif cmd == "actionbar" or cmd == "actions" then
        DSD:DetectActionBar()
        
    elseif cmd == "auras" or cmd == "buffs" then
        DSD:DetectAuras()
        
    elseif cmd == "start" or cmd == "logger" then
        DSD:StartCastLogger()
        
    elseif cmd == "stop" then
        DSD:StopCastLogger()
        
    elseif cmd == "export" or cmd == "all" then
        DSD:ExportAllSpells()
        
    elseif cmd == "find" then
        local spellName = string.sub(msg, 7)  -- Все после "find "
        DSD:FindSpellID(spellName)
        
    else
        DSD:Print("Неизвестная команда. Используйте /detect help")
    end
end

SlashCmdList["DETECT"] = HandleCommand

-- Вывод
function DSD:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF[Detector]|r "..msg)
end

-- Автозагрузка
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(1, function()
            DSD:Initialize()
        end)
    end
end)

DSD:Print("Детектор ID заклинаний загружен!")