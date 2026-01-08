-- ==============================================
-- DBM_Scanner - AI Rotation Master for WoW 7.3.5
-- ==============================================
local addonName = "DBM_Scanner"

-- Главная таблица аддона
DBM_Scanner = DBM_Scanner or {}
local DS = DBM_Scanner

-- Конфигурация
DS.version = "1.0.0"
DS.debug = true  -- Включен дебаг по умолчанию для отладки
DS.enabled = false
DS.isCasting = false
DS.lastCastTime = 0
DS.castDelay = 0.1  -- Задержка между кастами (сек)

-- Системные переменные
DS.Modules = {}
DS.ActiveModule = nil
DS.AIEngine = nil
DS.PlayerInfo = {
    class = nil,
    spec = nil,
    specID = nil
}

-- Регистр событий
DS.Events = CreateFrame("Frame")
DS.Events:RegisterEvent("PLAYER_LOGIN")
DS.Events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
DS.Events:RegisterEvent("PLAYER_TALENT_UPDATE")
DS.Events:RegisterEvent("SPELLS_CHANGED")
DS.Events:RegisterEvent("UNIT_SPELLCAST_START")
DS.Events:RegisterEvent("UNIT_SPELLCAST_STOP")
DS.Events:RegisterEvent("UNIT_SPELLCAST_FAILED")
DS.Events:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

elseif cmd == "learn" then
    if DS.AIEngine and DS.AIEngine.PrintLearningStatus then
        DS.AIEngine:PrintLearningStatus()
    else
        DS:Print("ИИ движок не доступен")
    end
	
	
-- Инициализация аддона
function DS:Initialize()
    self:Debug("=== DBM_Scanner Инициализация ===")
    
    -- Получение информации об игроке
    self:UpdatePlayerInfo()
    
    -- Загрузка компонентов
    self:LoadComponents()
    
    -- Загрузка модуля ротации для текущего класса/спека
    self:LoadRotationModule()
    
    -- Инициализация ИИ движка
    if DBM_Scanner_AI then
        DBM_Scanner_AI:Initialize()
        self.AIEngine = DBM_Scanner_AI
        self:Debug("ИИ движок загружен")
    end
    
    -- Загрузка интерфейса
    if DBM_Scanner_UI then
        DBM_Scanner_UI:Initialize()
        self:Debug("Интерфейс загружен")
    end
    
    self:Debug("=== Инициализация завершена ===")
    self:Print("DBM_Scanner v"..self.version.." загружен. Используйте /dbms для управления.")
end

-- Обновление информации об игроке
function DS:UpdatePlayerInfo()
    local _, class = UnitClass("player")
    local specID = GetSpecialization()
    local specName = specID and select(2, GetSpecializationInfo(specID)) or "None"
    
    self.PlayerInfo.class = class
    self.PlayerInfo.specID = specID
    self.PlayerInfo.spec = specName
    self.PlayerInfo.specNameLocalized = specName
end

-- Загрузка компонентов
function DS:LoadComponents()
    -- Автозагрузка компонентов (если они существуют)
    local components = {
        "DBM_Scanner_Spells",
        "DBM_Scanner_Training",
        "DBM_Scanner_AI",
        "DBM_Scanner_UI"
    }
    
    for _, component in ipairs(components) do
        if _G[component] then
            self:Debug("Компонент найден: "..component)
        else
            self:Debug("Компонент не найден: "..component)
        end
    end
end

-- Загрузка модуля ротации
function DS:LoadRotationModule()
    local class = self.PlayerInfo.class
    local spec = self.PlayerInfo.spec
    
    if not class then
        self:Debug("Ошибка: не удалось определить класс")
        return
    end
    
    -- Поиск модуля
    local moduleName = "DBM_Scanner_"..class
    local module = self.Modules[class] or _G[moduleName]
    
    if module then
        self.ActiveModule = module
        
        -- Инициализация модуля если есть функция
        if type(module.Initialize) == "function" then
            local success, err = pcall(module.Initialize)
            if success then
                self:Debug("Модуль ротации загружен: "..class)
                if spec and spec ~= "None" then
                    self:Debug("Специализация: "..spec)
                end
            else
                self:Debug("Ошибка инициализации модуля: "..tostring(err))
                self.ActiveModule = nil
            end
        else
            self:Debug("Модуль "..class.." загружен (без инициализации)")
        end
    else
        self:Debug("Модуль ротации не найден для класса: "..class)
        self:Print("|cFFFF0000Внимание:|r Модуль ротации для "..class.." не найден.")
        self:Print("Создайте файл "..moduleName..".lua в папке Modules")
    end
end

-- Регистрация модуля
function DS:RegisterModule(class, moduleTable)
    if not class or not moduleTable then
        self:Debug("Ошибка регистрации модуля")
        return false
    end
    
    self.Modules[class] = moduleTable
    self:Debug("Модуль зарегистрирован: "..class)
    return true
end

-- Получение текущего состояния игры для ИИ
function DS:GetGameState()
    local state = {
        timestamp = GetTime(),
        inCombat = UnitAffectingCombat("player"),
        isDead = UnitIsDeadOrGhost("player"),
        isCasting = (UnitCastingInfo("player") ~= nil) or (UnitChannelInfo("player") ~= nil),
        
        -- Ресурсы
        health = {current = UnitHealth("player"), max = UnitHealthMax("player"), percent = UnitHealth("player")/UnitHealthMax("player")*100},
        power = {current = UnitPower("player"), max = UnitPowerMax("player"), type = UnitPowerType("player")},
        
        -- Цель
        target = {
            exists = UnitExists("target"),
            dead = UnitIsDeadOrGhost("target"),
            distance = self:GetTargetDistance(),
            health = UnitExists("target") and (UnitHealth("target")/UnitHealthMax("target")*100) or 0,
            name = UnitExists("target") and UnitName("target") or nil
        },
        
        -- Группа/рейд
        inGroup = IsInGroup(),
        inRaid = IsInRaid(),
        groupSize = GetNumGroupMembers(),
        
        -- Специфичные для класса данные (заполняется модулем)
        classSpecific = {}
    }
    
    -- Если активен модуль, собираем дополнительные данные
    if self.ActiveModule and type(self.ActiveModule.GetClassState) == "function" then
        state.classSpecific = self.ActiveModule:GetClassState()
    end
    
    return state
end

-- Получение дистанции до цели (упрощенный метод)
function DS:GetTargetDistance()
    if not UnitExists("target") then return 999 end
    
    local inRange = IsSpellInRange("Автоатака", "target")
    if inRange == 1 then
        return 0  -- В ближней дистанции
    elseif inRange == 0 then
        return 999  -- Вне дистанции
    else
        return 30  -- Неопределенная дистанция (примерно)
    end
end

-- Активация/деактивация ротации
function DS:ToggleRotation(enable)
    if enable == nil then
        self.enabled = not self.enabled
    else
        self.enabled = enable
    end
    
    if self.enabled then
        self:Print("Ротация |cFF00FF00ВКЛЮЧЕНА|r")
        self:Debug("Автоматическая ротация активирована")
        
        -- Автоматически начинаем атаку если есть цель
        if UnitExists("target") and not UnitIsDeadOrGhost("target") then
            AttackTarget()
            self:Debug("Автоатака начата")
        end
    else
        self:Print("Ротация |cFFFF0000ВЫКЛЮЧЕНА|r")
        self:Debug("Автоматическая ротация деактивирована")
    end
end

-- ==============================================
-- ИСПРАВЛЕННАЯ ЧАСТЬ: ОСНОВНОЙ ЦИКЛ РОТАЦИИ
-- ==============================================

-- Основной цикл ротации (ИСПРАВЛЕННАЯ ВЕРСИЯ)
function DS:OnUpdate(elapsed)
    -- Проверка включена ли ротация
    if not self.enabled then return end
    
    -- Накопление времени для регулирования FPS
    self.UpdateFrame.accumulator = (self.UpdateFrame.accumulator or 0) + elapsed
    if self.UpdateFrame.accumulator < 0.05 then  -- 20 FPS (50ms)
        return
    end
    self.UpdateFrame.accumulator = 0
    
    -- ОТЛАДКА: Начало цикла
    self:Debug("=== Цикл ротации начат ===")
    
    -- Базовые проверки
    if UnitIsDeadOrGhost("player") then 
        self:Debug("Игрок мертв - выход")
        return 
    end
    
    if IsMounted() then 
        self:Debug("На транспорте - выход")
        return 
    end
    
    -- Проверка каста (со сбросом флага если каст завершен)
    local castingInfo = UnitCastingInfo("player")
    local channelInfo = UnitChannelInfo("player")
    
    if castingInfo or channelInfo then
        self.isCasting = true
        self:Debug("Уже кастует: "..(castingInfo or channelInfo))
        return
    else
        self.isCasting = false
    end
    
    -- Проверка цели
    if not UnitExists("target") then 
        self:Debug("Нет цели - выход")
        return 
    end
    
    if UnitIsDeadOrGhost("target") then 
        self:Debug("Цель мертва - выход")
        return 
    end
    
    if not UnitCanAttack("player", "target") then 
        self:Debug("Не могу атаковать цель - выход")
        return 
    end
    
    -- Проверка задержки между кастами
    local currentTime = GetTime()
    if currentTime - self.lastCastTime < self.castDelay then
        self:Debug("Задержка между кастами: "..(currentTime - self.lastCastTime))
        return
    end
    
    -- Получение текущего состояния
    local state = self:GetGameState()
    self:Debug("Состояние получено. В бою: "..tostring(state.inCombat))
    
    -- Получаем решение от ИИ или модуля
    local spellToCast = nil
    
    -- 1. Пробуем получить решение от ИИ
    if self.AIEngine and self.AIEngine.isLearning then
        self:Debug("Запрашиваю решение у ИИ...")
        spellToCast = self.AIEngine:GetDecision(state, self.ActiveModule)
        if spellToCast then
            self:Debug("ИИ выбрал: "..(spellToCast.name or "неизвестно"))
        else
            self:Debug("ИИ не дал решение")
        end
    end
    
    -- 2. Если ИИ не дал решение, используем модуль
    if not spellToCast and self.ActiveModule and type(self.ActiveModule.GetRotation) == "function" then
        self:Debug("ИИ не дал решение, запрашиваю у модуля...")
        spellToCast = self.ActiveModule:GetRotation(state)
        if spellToCast then
            self:Debug("Модуль выбрал: "..(spellToCast.name or "неизвестно"))
        else
            self:Debug("Модуль не дал решение")
        end
    end
    
    -- 3. Если всё ещё нет решения, используем простую логику
    if not spellToCast then
        self:Debug("Нет решения от ИИ/модуля, использую простую логику...")
        spellToCast = self:GetSimpleSpell(state)
    end
    
  -- Применение заклинания
    if spellToCast then
    self.lastSpell = spellToCast
    local success = self:CastSpell(spellToCast)
    
    if success then
        self.lastCastTime = GetTime()
        self:Debug("УСПЕШНО кастуем: "..(spellToCast.name or tostring(spellToCast)))
        
        -- ОЦЕНИВАЕМ РЕЗУЛЬТАТ (для обучения ИИ)
          if self.AIEngine and self.AIEngine.EvaluateSimple then
            C_Timer.After(1.0, function()  -- Через 1 секунду оцениваем результат
                self.AIEngine:EvaluateSimple()
             end)
          end
       else
        self:Debug("НЕ УДАЛОСЬ кастовать: "..(spellToCast.name or tostring(spellToCast)))
       end
    end
        self:Debug("Нет заклинаний для каста")
        
        -- Если нет заклинаний для каста, запускаем автоатаку
        if not UnitAffectingCombat("player") then
            AttackTarget()
            self:Debug("Запускаю автоатаку")
        end
    end
end

-- Простая логика выбора заклинания (ИСПРАВЛЕННАЯ)
function DS:GetSimpleSpell(state)
    self:Debug("Поиск простого боевого заклинания...")
    
    -- Используем кэш сканера заклинаний если доступен
    if DBM_Scanner_Spells and DBM_Scanner_Spells.spellCategories then
        -- Берем только сингл-таргет заклинания
        local singleTarget = DBM_Scanner_Spells.spellCategories.singleTarget or {}
        
        for _, spell in ipairs(singleTarget) do
            if self:IsSpellReadyForCombat(spell) then
                self:Debug("Найдено из категории: "..spell.name)
                return spell
            end
        end
    end
    
    -- Если сканера нет, ищем вручную (оптимизированно)
    local spellIDs = {  -- Примерные ID боевых заклинаний по классам
        -- Шаман усиление
        SHAMAN = {17364, 60103, 187874, 193796, 196834, 193786, 197992, 51533, 204945, 197214},
        -- Воин
        WARRIOR = {23881, 23894, 12294, 46924, 57755, 184367, 190411},
        -- Охотник
        HUNTER = {56641, 19434, 3044, 53301, 193455},
        -- Разбойник
        ROGUE = {53, 1752, 196819, 185763, 195452},
        -- Маг
        MAGE = {133, 116, 44614, 30451, 11366},
        -- Чернокнижник
        WARLOCK = {686, 348, 29722, 17877, 30108},
        -- Жрец
        PRIEST = {585, 589, 34914, 32379, 2050},
        -- Паладин
        PALADIN = {35395, 20271, 26573, 85256, 184575},
        -- Друид
        DRUID = {5176, 339, 5221, 102792, 1822},
        -- Рыцарь смерти
        DEATHKNIGHT = {49998, 47541, 55050, 49143, 49020}
    }
    
    local classSpells = spellIDs[self.PlayerInfo.class] or {}
    
    for _, spellID in ipairs(classSpells) do
        if IsSpellKnown(spellID) then
            local name = GetSpellInfo(spellID)
            if name and self:IsSpellReadyForCombat({id = spellID, name = name}) then
                self:Debug("Найдено по ID: "..name)
                return {id = spellID, name = name}
            end
        end
    end
    
    -- Последняя попытка: найти любое боевое заклинание
    for i = 1, 500 do  -- Только первые 500 для производительности
        local name, _, _, castTime, _, _, id = GetSpellInfo(i)
        if name and IsSpellKnown(i) and not IsPassiveSpell(i) then
            if castTime and castTime >= 0 then  -- Только с нормальным временем каста
                if self:IsSpellReadyForCombat({id = i, name = name}) then
                    self:Debug("Найдено в быстром поиске: "..name)
                    return {id = i, name = name}
                end
            end
        end
    end
    
    self:Debug("Боевые заклинания не найдены")
    return nil
end

-- Проверка готовности заклинания для боя
function DS:IsSpellReadyForCombat(spell)
    if not spell or not spell.id then return false end
    
    -- Проверка КД
    local start, duration = GetSpellCooldown(spell.id)
    if start > 0 then
        return false
    end
    
    -- Проверка доступности
    if not IsUsableSpell(spell.id) then
        return false
    end
    
    -- Проверка дистанции
    if UnitExists("target") then
        local inRange = IsSpellInRange(spell.name or spell.id, "target")
        if inRange == 0 then
            return false
        end
    end
    
    return true
end

-- Улучшенный каст заклинания
function DS:CastSpell(spellInfo)
    if not spellInfo then 
        self:Debug("CastSpell: нет информации о заклинании")
        return false 
    end
    
    local spellName, spellID
    
    if type(spellInfo) == "table" then
        spellName = spellInfo.name
        spellID = spellInfo.id
    elseif type(spellInfo) == "string" then
        spellName = spellInfo
    elseif type(spellInfo) == "number" then
        spellID = spellInfo
        spellName = GetSpellInfo(spellID)
    end
    
    self:Debug("Попытка каста: "..(spellName or "unknown").." (ID: "..tostring(spellID)..")")
    
    -- Приоритет: ID > Name
    if spellID then
        -- Проверяем доступность
        if IsUsableSpell(spellID) then
            local start, duration = GetSpellCooldown(spellID)
            if start == 0 then
                self:Debug("Кастую по ID: "..spellID)
                CastSpellByID(spellID, "target")
                return true
            else
                local remaining = duration - (GetTime() - start)
                self:Debug("Заклинание на КД: "..string.format("%.1f", remaining).." сек")
            end
        else
            self:Debug("Заклинание не доступно по ID: "..spellID)
        end
    end
    
    if spellName then
        -- Проверяем доступность
        if IsUsableSpell(spellName) then
            local start, duration = GetSpellCooldown(spellName)
            if start == 0 then
                self:Debug("Кастую по имени: "..spellName)
                CastSpellByName(spellName, "target")
                return true
            else
                local remaining = duration - (GetTime() - start)
                self:Debug("Заклинание на КД: "..string.format("%.1f", remaining).." сек")
            end
        else
            self:Debug("Заклинание не доступно по имени: "..spellName)
        end
    end
    
    self:Debug("Заклинание недоступно: "..(spellName or tostring(spellID)))
    return false
end

-- ==============================================
-- КОНЕЦ ИСПРАВЛЕННОЙ ЧАСТИ
-- ==============================================

-- Обработчик событий кастов
DS.Events:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        DS:Initialize()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        DS:UpdatePlayerInfo()
        DS:LoadRotationModule()
        DS:Debug("Специализация изменена: "..(DS.PlayerInfo.spec or "Unknown"))
    elseif event == "PLAYER_TALENT_UPDATE" then
        DS:Debug("Таланты обновлены")
    elseif event == "SPELLS_CHANGED" then
        DS:Debug("Заклинания изменены")
    elseif event == "UNIT_SPELLCAST_START" then
        local unit, spellName = ...
        if unit == "player" then
            DS.isCasting = true
            DS:Debug("Начал каст: "..spellName)
        end
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit = ...
        if unit == "player" then
            DS.isCasting = false
            DS:Debug("Каст завершен/прерван")
        end
    end
end)

-- Настройка основного цикла
DS.UpdateFrame = CreateFrame("Frame")
DS.UpdateFrame.lastUpdate = 0
DS.UpdateFrame.accumulator = 0
DS.UpdateFrame:SetScript("OnUpdate", function(self, elapsed)
    DS.UpdateFrame.lastUpdate = DS.UpdateFrame.lastUpdate + elapsed
    DS:OnUpdate(DS.UpdateFrame.lastUpdate)
    DS.UpdateFrame.lastUpdate = 0
end)

-- Функции для вывода сообщений
function DS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFDBM_Scanner:|r "..msg)
end

function DS:Debug(msg)
    if self.debug then
        self:Print("|cFFFFFF00[DEBUG]|r "..msg)
    end
end

-- Слэш команды
SLASH_DBMSCANNER1 = "/dbms"
SLASH_DBMSCANNER2 = "/dbmscanner"

SlashCmdList["DBMSCANNER"] = function(msg)
    local cmd = string.lower(msg or "")
    
    if cmd == "on" or cmd == "вкл" or cmd == "enable" then
        DS:ToggleRotation(true)
    elseif cmd == "off" or cmd == "выкл" or cmd == "disable" then
        DS:ToggleRotation(false)
    elseif cmd == "toggle" or cmd == "тоггл" then
        DS:ToggleRotation()
    elseif cmd == "debug" then
        DS.debug = not DS.debug
        DS:Print("Режим отладки: "..(DS.debug and "|cFF00FF00ВКЛ|r" or "|cFFFF0000ВЫКЛ|r"))
    elseif cmd == "status" or cmd == "статус" then
        DS:Print("=== Статус DBM_Scanner ===")
        DS:Print("Версия: "..DS.version)
        DS:Print("Состояние: "..(DS.enabled and "|cFF00FF00АКТИВНО|r" or "|cFFFF0000НЕАКТИВНО|r"))
        DS:Print("Класс: "..(DS.PlayerInfo.class or "Неизвестно"))
        DS:Print("Спек: "..(DS.PlayerInfo.spec or "Неизвестно"))
        DS:Print("Модуль: "..(DS.ActiveModule and "Загружен" or "|cFFFF0000Не найден|r"))
        DS:Print("ИИ движок: "..(DS.AIEngine and "Доступен" or "Недоступен"))
        DS:Print("Цель: "..(UnitExists("target") and UnitName("target") or "|cFFFF0000Нет|r"))
        if UnitExists("target") then
            DS:Print("Можно атаковать: "..(UnitCanAttack("player", "target") and "|cFF00FF00Да|r" or "|cFFFF0000Нет|r"))
            DS:Print("В бою: "..(UnitAffectingCombat("player") and "|cFF00FF00Да|r" or "|cFFFF0000Нет|r"))
        end
    elseif cmd == "train" or cmd == "тренировка" then
        if DBM_Scanner_Training then
            DBM_Scanner_Training:StartTraining()
        else
            DS:Print("Модуль тренировки не загружен")
        end
    elseif cmd == "scan" or cmd == "сканирование" then
        if DBM_Scanner_Spells then
            DBM_Scanner_Spells:ScanAllSpells()
        else
            DS:Print("Модуль сканирования не загружен")
        end
    elseif cmd == "ai" then
        if DS.AIEngine then
            DS.AIEngine:PrintStatus()
        else
            DS:Print("ИИ движок не загружен")
        end
    elseif cmd == "test" then
        DS:Print("=== ТЕСТ РОТАЦИИ ===")
        DS:Print("Включено: "..tostring(DS.enabled))
        DS:Print("Модуль: "..tostring(DS.ActiveModule and "Да" or "Нет"))
        DS:Print("ИИ: "..tostring(DS.AIEngine and "Да" or "Нет"))
        DS:Print("Цель: "..(UnitExists("target") and UnitName("target") or "Нет"))
        
        if UnitExists("target") then
            DS:Print("Можно атаковать: "..tostring(UnitCanAttack("player", "target")))
            DS:Print("В бою: "..tostring(UnitAffectingCombat("player")))
            
            -- Тест простого заклинания
            local spell = DS:GetSimpleSpell({})
            if spell then
                DS:Print("Тестовое заклинание: "..spell.name)
                DS:CastSpell(spell)
            else
                DS:Print("Тестовое заклинание не найдено")
            end
        end
    elseif cmd == "casttest" then
        -- Быстрый тест каста первого найденного заклинания
        if UnitExists("target") then
            for i = 1, 1000 do
                local name = GetSpellInfo(i)
                if name and IsSpellKnown(i) and not IsPassiveSpell(i) then
                    DS:Print("Тест каста: "..name)
                    CastSpellByID(i, "target")
                    break
                end
            end
        else
            DS:Print("Нет цели для теста!")
        end
    elseif cmd == "help" or cmd == "помощь" or cmd == "" then
        DS:Print("=== Команды DBM_Scanner ===")
        DS:Print("|cFFFFFF00/dbms on|r - Включить ротацию")
        DS:Print("|cFFFFFF00/dbms off|r - Выключить ротацию")
        DS:Print("|cFFFFFF00/dbms toggle|r - Переключить ротацию")
        DS:Print("|cFFFFFF00/dbms debug|r - Вкл/выкл отладку")
        DS:Print("|cFFFFFF00/dbms status|r - Показать статус")
        DS:Print("|cFFFFFF00/dbms test|r - Тест ротации")
        DS:Print("|cFFFFFF00/dbms casttest|r - Тест каста")
        DS:Print("|cFFFFFF00/dbms train|r - Начать тренировку")
        DS:Print("|cFFFFFF00/dbms scan|r - Сканировать заклинания")
        DS:Print("|cFFFFFF00/dbms ai|r - Статус ИИ")
        DS:Print("|cFFFFFF00/dbms help|r - Эта справка")
    else
        DS:Print("Неизвестная команда. Введите |cFFFFFF00/dbms help|r для списка команд.")
    end
end

-- Сообщение о загрузке
DS:Print("Аддон DBM_Scanner загружен. Ожидание входа в игру...")