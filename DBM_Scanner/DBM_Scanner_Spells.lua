-- ==============================================
-- DBM_Scanner_Spells - Ручной сборщик заклинаний
-- ==============================================
local addonName = "DBM_Scanner_Spells"

DBM_Scanner_Spells = DBM_Scanner_Spells or {}
local DSS = DBM_Scanner_Spells

-- Конфигурация
DSS.version = "4.0.0"
DSS.SpellsByClass = {}
DSS.learningMode = false
DSS.lastSpellCast = nil

-- Инициализация
function DSS:Initialize()
    self:Print("Ручной сборщик заклинаний v"..self.version)
    self.playerClass = select(2, UnitClass("player"))
    
    -- Загружаем сохраненные заклинания
    self:LoadSavedSpells()
    
    -- Хук на каст заклинаний
    self:HookSpellCasting()
    
    self:Print("Готов! Используйте /spells help")
end

-- Хук для отслеживания кастов
function DSS:HookSpellCasting()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    frame:SetScript("OnEvent", function(self, event, unit, _, spellID)
        if event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" then
            DSS:OnSpellCast(spellID)
        end
    end)
end

-- Обработчик каста заклинания
function DSS:OnSpellCast(spellID)
    if not spellID or spellID == 0 then return end
    
    local name, _, _, castTime = GetSpellInfo(spellID)
    if not name then return end
    
    self.lastSpellCast = {
        id = spellID,
        name = name,
        castTime = castTime or 0,
        timestamp = GetTime()
    }
    
    -- Если включен режим обучения, добавляем автоматически
    if self.learningMode and self:IsCombatSpell(name) then
        self:AddSpellManual(spellID, name)
    end
end

-- Авто-детект при касте (добавьте в OnSpellCast)
function DSS:OnSpellCast(spellID)
    if not spellID or spellID == 0 then return end
    
    local name, _, _, castTime, _, _, actualID = GetSpellInfo(spellID)
    if not name then return end
    
    -- Используем actualID если он есть (важно для кастомных серверов)
    local realID = actualID or spellID
    
    self.lastSpellCast = {
        id = realID,  -- ← ВОТ ЭТО ВАЖНО!
        name = name,
        castTime = castTime or 0,
        timestamp = GetTime()
    }
    
    self:Print("|cFFFFFF00Обнаружено: "..name.." (ID: "..realID..")|r")
    
    if self.learningMode then
        self:AddSpellManual(realID, name)
    end
end

-- Ручное добавление текущего заклинания
function DSS:AddLastSpell()
    if not self.lastSpellCast then
        self:Print("|cFFFF0000Нет информации о последнем заклинании|r")
        return false
    end
    
    return self:AddSpellManual(self.lastSpellCast.id, self.lastSpellCast.name)
end

-- Ручное добавление по ID или имени
function DSS:AddSpellManual(spellID, spellName)
    local id = spellID
    local name = spellName
    
    -- Если передано только имя, ищем ID
    if not id and name then
        id = self:FindSpellIDByName(name)
    end
    
    -- Если передано только ID, получаем имя
    if id and not name then
        name = GetSpellInfo(id)
    end
    
    if not id or not name then
        self:Print("|cFFFF0000Не удалось определить заклинание|r")
        return false
    end
    
    -- Проверяем что заклинание известно
    if not IsSpellKnown(id) and not IsPlayerSpell(id) then
        self:Print("|cFFFF0000Заклинание не известно игроку: "..name.."|r")
        return false
    end
    
    -- Проверяем что оно боевое
    if not self:IsCombatSpell(name) then
        self:Print("|cFFFF0000Не боевое заклинание: "..name.."|r")
        return false
    end
    
    -- Добавляем в список
    if not self.SpellsByClass[self.playerClass] then
        self.SpellsByClass[self.playerClass] = {}
    end
    
    -- Проверяем нет ли уже такого заклинания
    for _, spell in ipairs(self.SpellsByClass[self.playerClass]) do
        if spell.id == id or spell.name == name then
            self:Print("|cFFFFFF00Заклинание уже в списке: "..name.."|r")
            return false
        end
    end
    
    -- Получаем полную информацию
    local _, _, _, castTime, minRange, maxRange = GetSpellInfo(id)
    
    local spellData = {
        id = id,
        name = name,
        castTime = castTime or 0,
        minRange = minRange or 0,
        maxRange = maxRange or 0,
        addedManually = true,
        addedTime = time()
    }
    
    table.insert(self.SpellsByClass[self.playerClass], spellData)
    
    -- Сохраняем
    self:SaveSpells()
    
    self:Print("|cFF00FF00✓ Добавлено: "..name.." (ID: "..id..")|r")
    return true
end

-- Поиск ID по имени
function DSS:FindSpellIDByName(spellName)
    if not spellName then return nil end
    
    -- Проверяем диапазон ID
    for i = 1, 50000 do
        local name = GetSpellInfo(i)
        if name and string.lower(name) == string.lower(spellName) then
            if IsSpellKnown(i) or IsPlayerSpell(i) then
                return i
            end
        end
    end
    
    return nil
end

-- Добавление заклинания из чата
function DSS:AddFromChat(input)
    local input = string.trim(input or "")
    
    if input == "" then
        self:Print("Укажите ID или название заклинания")
        self:Print("Пример: /spells add 17364")
        self:Print("Пример: /spells add 'Удар бури'")
        return
    end
    
    -- Пробуем как число (ID)
    local asNumber = tonumber(input)
    if asNumber then
        self:AddSpellManual(asNumber, nil)
        return
    end
    
    -- Иначе как название
    self:AddSpellManual(nil, input)
end

-- Режим авто-обучения
function DSS:ToggleLearningMode()
    self.learningMode = not self.learningMode
    
    if self.learningMode then
        self:Print("|cFF00FF00РЕЖИМ ОБУЧЕНИЯ ВКЛЮЧЕН|r")
        self:Print("Все кастуемые боевые заклинания будут добавляться автоматически")
        self:Print("Поработайте с манекеном 2-3 минуты")
    else
        self:Print("|cFFFF0000Режим обучения выключен|r")
    end
end

-- Быстрое обучение на манекене
function DSS:QuickTrain()
    self:Print("|cFFFF0000=== БЫСТРОЕ ОБУЧЕНИЕ ===|r")
    self:Print("1. Включен режим обучения")
    self:Print("2. Перейдите к манекену")
    self:Print("3. Используйте ВСЕ свои боевые заклинания")
    self:Print("4. Каждое заклинание добавится автоматически")
    self:Print("5. Через 2 минуты выключите обучение")
    
    self.learningMode = true
end

-- Проверка что заклинание боевое (упрощенная)
function DSS:IsCombatSpell(name)
    if not name then return false end
    
    local lowerName = string.lower(name)
    
    -- Очевидно не боевые
    local nonCombat = {
        "професси", "ремесл", "телепорт", "портал", "воскрешение",
        "оживление", "дух", "ритуал", "пир", "еда", "питье", "банкет",
        "стол", "кухня", "приготов", "питание", "напиток", "умение",
        "мастерство", "навык", "способность", "талант"
    }
    
    for _, word in ipairs(nonCombat) do
        if string.find(lowerName, word) then
            return false
        end
    end
    
    -- Если прошло проверку, считаем боевым
    return true
end

-- Показать список
function DSS:ShowList()
    local spells = self.SpellsByClass[self.playerClass]
    
    if not spells or #spells == 0 then
        self:Print("|cFFFF0000Список заклинаний пуст|r")
        self:Print("Добавьте заклинания командой /spells add [ID/название]")
        self:Print("Или включите режим обучения: /spells learn")
        return
    end
    
    self:Print("=== Ваши заклинания ("..#spells..") ===")
    
    table.sort(spells, function(a, b) return a.name < b.name end)
    
    for i, spell in ipairs(spells) do
        local castText = spell.castTime > 0 and string.format("%.1fс", spell.castTime) or "мгнов."
        local manualText = spell.addedManually and " [ручное]" or ""
        self:Print(string.format("%2d. %-25s (ID: %d, %s)%s", 
            i, spell.name, spell.id, castText, manualText))
    end
end

-- Удалить заклинание
function DSS:RemoveSpell(index)
    local spells = self.SpellsByClass[self.playerClass]
    
    if not spells or #spells == 0 then
        self:Print("Список пуст")
        return
    end
    
    index = tonumber(index)
    if not index or index < 1 or index > #spells then
        self:Print("Неверный номер. Используйте /spells list")
        return
    end
    
    local removed = table.remove(spells, index)
    self:SaveSpells()
    
    self:Print("|cFFFF0000Удалено: "..removed.name.."|r")
end

-- Очистить список
function DSS:ClearList()
    self.SpellsByClass[self.playerClass] = {}
    self:SaveSpells()
    self:Print("|cFFFF0000Список очищен|r")
end

-- Сохранение
function DSS:SaveSpells()
    if self.playerClass then
        _G["DBM_Spells_"..self.playerClass] = self.SpellsByClass[self.playerClass]
        self:Print("Заклинания сохранены")
    end
end

-- Загрузка
function DSS:LoadSavedSpells()
    if self.playerClass then
        local saved = _G["DBM_Spells_"..self.playerClass]
        if saved then
            self.SpellsByClass[self.playerClass] = saved
            self:Print("Загружено "..#saved.." сохраненных заклинаний")
        end
    end
end

-- Экспорт списка
function DSS:ExportList()
    local spells = self.SpellsByClass[self.playerClass]
    
    if not spells or #spells == 0 then
        self:Print("Нет заклинаний для экспорта")
        return
    end
    
    self:Print("=== ЭКСПОРТ ДЛЯ DBM_Scanner_AI.lua ===")
    self:Print("-- Вставьте этот код в функцию GetAvailableActions:")
    self:Print("local manualSpells = {")
    
    for _, spell in ipairs(spells) do
        self:Print(string.format("    {id = %d, name = \"%s\", castTime = %.1f},", 
            spell.id, spell.name, spell.castTime or 0))
    end
    
    self:Print("}")
    self:Print("-- Затем добавьте manualSpells в actions")
end

-- ==============================================
-- КОМАНДЫ
-- ==============================================

SLASH_SPELLS1 = "/spells"
SLASH_SPELLS2 = "/dbmspells"

local function HandleCommand(msg)
    msg = msg or ""
    local args = {}
    
    for arg in string.gmatch(msg, "%S+") do
        table.insert(args, arg)
    end
    
    local cmd = args[1] or ""
    cmd = string.lower(cmd)
    
    if cmd == "" then
        DSS:ShowList()
        
    elseif cmd == "add" then
        local input = string.sub(msg, 5)  -- Все после "add "
        DSS:AddFromChat(input)
        
    elseif cmd == "last" or cmd == "добавить" then
        DSS:AddLastSpell()
        
    elseif cmd == "learn" or cmd == "обучение" then
        DSS:ToggleLearningMode()
        
    elseif cmd == "quicktrain" then
        DSS:QuickTrain()
        
    elseif cmd == "list" or cmd == "список" then
        DSS:ShowList()
        
    elseif cmd == "remove" or cmd == "удалить" then
        DSS:RemoveSpell(args[2])
        
    elseif cmd == "clear" or cmd == "очистить" then
        DSS:ClearList()
        
    elseif cmd == "export" then
        DSS:ExportList()
        
    elseif cmd == "test" then
        DSS:Print("Последнее кастованное: "..(DSS.lastSpellCast and DSS.lastSpellCast.name or "нет"))
        
    elseif cmd == "help" or cmd == "помощь" then
        DSS:Print("=== КОМАНДЫ РУЧНОГО СБОРЩИКА ===")
        DSS:Print("|cFFFFFF00/spells|r - Показать список")
        DSS:Print("|cFFFFFF00/spells add [ID/название]|r - Добавить заклинание")
        DSS:Print("|cFFFFFF00/spells last|r - Добавить последнее кастованное")
        DSS:Print("|cFFFFFF00/spells learn|r - Вкл/выкл авто-добавление")
        DSS:Print("|cFFFFFF00/spells quicktrain|r - Быстрое обучение")
        DSS:Print("|cFFFFFF00/spells remove [номер]|r - Удалить заклинание")
        DSS:Print("|cFFFFFF00/spells clear|r - Очистить список")
        DSS:Print("|cFFFFFF00/spells export|r - Экспорт для ИИ")
        DSS:Print("|cFFFFFF00/spells help|r - Справка")
        
    else
        DSS:Print("Неизвестная команда. Используйте /spells help")
    end
end

SlashCmdList["SPELLS"] = HandleCommand

-- Вывод в чат
function DSS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[DBM Spells]|r "..msg)
end

-- Автозагрузка
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(1, function()
            DSS:Initialize()
        end)
    end
end)


DSS:Print("Ручной сборщик заклинаний загружен!")