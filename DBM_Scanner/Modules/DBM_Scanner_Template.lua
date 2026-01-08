-- ==============================================
-- DBM_Scanner_Template - Template for Class Modules
-- ==============================================
local addonName = "DBM_Scanner_Template"

-- Шаблон модуля класса
DBM_Scanner_Template = DBM_Scanner_Template or {}
local DSTemplate = DBM_Scanner_Template

-- Базовые функции модуля
DSTemplate.ClassModule = {
    -- === ОБЯЗАТЕЛЬНЫЕ ФУНКЦИИ ===
    
    -- Инициализация модуля
    Initialize = function(self)
        self:Debug("Инициализация модуля класса")
        
        -- Получение информации о классе
        self.className, self.classFile = UnitClass("player")
        self.specID = GetSpecialization()
        self.specName = self.specID and select(2, GetSpecializationInfo(self.specID)) or "Unknown"
        
        -- Инициализация данных
        self.spells = {}
        self.talents = {}
        self.rotation = {}
        self.classState = {}
        
        -- Сканирование заклинаний
        self:ScanClassSpells()
        
        -- Сканирование талантов
        self:ScanTalents()
        
        -- Построение начальной ротации
        self:BuildInitialRotation()
        
        self:Debug("Модуль класса инициализирован: "..self.className.." ("..self.specName..")")
        return true
    end,
    
    -- Получение ротации (основная функция)
    GetRotation = function(self, gameState)
        -- gameState: таблица состояния игры из ядра
        
        -- Проверка условий
        if not self:CheckConditions(gameState) then
            return nil
        end
        
        -- Получение доступных заклинаний
        local availableSpells = self:GetAvailableSpells(gameState)
        if not availableSpells or #availableSpells == 0 then
            return nil
        end
        
        -- Выбор заклинания на основе логики класса
        local chosenSpell = self:ChooseSpell(availableSpells, gameState)
        
        return chosenSpell
    end,
    
    -- Получение состояния класса
    GetClassState = function(self)
        return self.classState
    end,
    
    -- === ОПЦИОНАЛЬНЫЕ ФУНКЦИИ ===
    
    -- Получение доступных заклинаний
    GetAvailableSpells = function(self, gameState)
        local available = {}
        
        for _, spell in ipairs(self.rotation) do
            if self:IsSpellUsable(spell, gameState) then
                table.insert(available, spell)
            end
        end
        
        return available
    end,
    
    -- Проверка условий для ротации
    CheckConditions = function(self, gameState)
        -- Базовые проверки
        if UnitIsDeadOrGhost("player") then return false end
        if IsMounted() then return false end
        if UnitCastingInfo("player") or UnitChannelInfo("player") then return false end
        if not UnitExists("target") then return false end
        if UnitIsDeadOrGhost("target") then return false end
        if not UnitCanAttack("player", "target") then return false end
        
        -- Класс-специфичные проверки
        if not self:ClassSpecificConditions(gameState) then
            return false
        end
        
        return true
    end,
    
    -- Класс-специфичные условия (переопределить)
    ClassSpecificConditions = function(self, gameState)
        return true
    end,
    
    -- Выбор заклинания (базовая логика)
    ChooseSpell = function(self, spells, gameState)
        if not spells or #spells == 0 then return nil end
        
        -- Базовая логика: первое доступное заклинание
        return spells[1]
    end,
    
    -- Проверка можно ли использовать заклинание
    IsSpellUsable = function(self, spell, gameState)
        if not spell then return false end
        
        local spellID = spell.id or spell.name
        if not spellID then return false end
        
        -- Проверка на КД
        local start, duration = GetSpellCooldown(spellID)
        if start > 0 then return false end
        
        -- Проверка на доступность ресурсов
        if not IsUsableSpell(spellID) then return false end
        
        -- Проверка дистанции
        if UnitExists("target") then
            local inRange = IsSpellInRange(spell.name or spellID, "target")
            if inRange == 0 then return false end
        end
        
        -- Класс-специфичные проверки
        if not self:SpellSpecificConditions(spell, gameState) then
            return false
        end
        
        return true
    end,
    
    -- Условия для конкретного заклинания (переопределить)
    SpellSpecificConditions = function(self, spell, gameState)
        return true
    end,
    
    -- Сканирование заклинаний класса
    ScanClassSpells = function(self)
        self:Debug("Сканирование заклинаний класса...")
        
        local classSpells = {}
        
        -- Используем глобальный сканер если доступен
        if DBM_Scanner_Spells then
            local spells = DBM_Scanner_Spells:ScanCombatSpells()
            for _, spell in ipairs(spells) do
                -- Фильтруем по классу (опционально)
                table.insert(classSpells, spell)
            end
        else
            -- Ручное сканирование
            for i = 1, 500000 do
                local name, _, _, castTime, _, _, id = GetSpellInfo(i)
                if name and IsSpellKnown(i) and not IsPassiveSpell(i) then
                    table.insert(classSpells, {
                        id = i,
                        name = name,
                        castTime = castTime
                    })
                end
            end
        end
        
        self.spells = classSpells
        self:Debug("Найдено заклинаний: "..#classSpells)
        
        return classSpells
    end,
    
    -- Сканирование талантов
    ScanTalents = function(self)
        self.talents = {}
        
        for tab = 1, GetNumTalentTabs() do
            for talent = 1, GetNumTalents(tab) do
                local name, icon, tier, column, _, _, _, _, _, isLearnable = GetTalentInfo(tab, talent)
                if name then
                    table.insert(self.talents, {
                        name = name,
                        icon = icon,
                        tier = tier,
                        column = column,
                        isSelected = GetSelectedTalent(tab, tier) == column
                    })
                end
            end
        end
        
        self:Debug("Найдено талантов: "..#self.talents)
        return self.talents
    end,
    
    -- Построение начальной ротации
    BuildInitialRotation = function(self)
        self:Debug("Построение начальной ротации...")
        
        -- Простая ротация: сортировка по силе (предполагаемой)
        table.sort(self.spells, function(a, b)
            -- Сначала мгновенные заклинания
            if a.castTime == 0 and b.castTime > 0 then return true end
            if a.castTime > 0 and b.castTime == 0 then return false end
            
            -- Потом по ID (грубое приближение силы)
            return (a.id or 0) > (b.id or 0)
        end)
        
        self.rotation = self.spells
        self:Debug("Построена ротация из "..#self.rotation.." заклинаний")
        
        return self.rotation
    end,
    
    -- Обновление состояния класса
    UpdateClassState = function(self)
        self.classState = {
            -- Базовые параметры
            resources = self:GetResources(),
            auras = self:GetAuras(),
            talents = self:GetActiveTalents(),
            
            -- Класс-специфичные параметры
            classSpecific = self:GetClassSpecificState()
        }
    end,
    
    -- Получение ресурсов
    GetResources = function(self)
        return {
            health = {current = UnitHealth("player"), max = UnitHealthMax("player"), percent = UnitHealth("player")/UnitHealthMax("player")*100},
            power = {current = UnitPower("player"), max = UnitPowerMax("player"), type = UnitPowerType("player")},
            secondary = self:GetSecondaryResources()
        }
    end,
    
    -- Вторичные ресурсы (переопределить)
    GetSecondaryResources = function(self)
        return {}
    end,
    
    -- Получение аур
    GetAuras = function(self)
        local auras = {
            buffs = {},
            debuffsOnTarget = {}
        }
        
        -- Баффы на игроке
        for i = 1, 40 do
            local name, _, _, _, duration, expires, _, _, _, spellId = UnitBuff("player", i)
            if not name then break end
            table.insert(auras.buffs, {
                name = name,
                spellId = spellId,
                expires = expires,
                duration = duration,
                remaining = expires - GetTime()
            })
        end
        
        -- Дебаффы на цели
        if UnitExists("target") then
            for i = 1, 40 do
                local name, _, _, _, duration, expires, _, _, _, spellId = UnitDebuff("target", i)
                if not name then break end
                table.insert(auras.debuffsOnTarget, {
                    name = name,
                    spellId = spellId,
                    expires = expires,
                    duration = duration,
                    remaining = expires - GetTime()
                })
            end
        end
        
        return auras
    end,
    
    -- Получение активных талантов
    GetActiveTalents = function(self)
        local active = {}
        
        for _, talent in ipairs(self.talents) do
            if talent.isSelected then
                table.insert(active, talent.name)
            end
        end
        
        return active
    end,
    
    -- Класс-специфичное состояние (переопределить)
    GetClassSpecificState = function(self)
        return {}
    end,
    
    -- === УТИЛИТЫ ===
    
    -- Поиск заклинания по имени
    FindSpellByName = function(self, spellName)
        for _, spell in ipairs(self.spells) do
            if spell.name == spellName then
                return spell
            end
        end
        return nil
    end,
    
    -- Поиск заклинания по ID
    FindSpellByID = function(self, spellID)
        for _, spell in ipairs(self.spells) do
            if spell.id == spellID then
                return spell
            end
        end
        return nil
    end,
    
    -- Получение времени восстановления заклинания
    GetSpellCooldownRemaining = function(self, spell)
        local spellID = spell.id or spell.name
        if not spellID then return 999 end
        
        local start, duration = GetSpellCooldown(spellID)
        if start == 0 then return 0 end
        
        return duration - (GetTime() - start)
    end,
    
    -- Проверка есть ли бафф
    HasBuff = function(self, buffName)
        for i = 1, 40 do
            local name = UnitBuff("player", i)
            if not name then break end
            if name == buffName then
                return true
            end
        end
        return false
    end,
    
    -- Проверка есть ли дебафф на цели
    TargetHasDebuff = function(self, debuffName)
        if not UnitExists("target") then return false end
        
        for i = 1, 40 do
            local name = UnitDebuff("target", i)
            if not name then break end
            if name == debuffName then
                return true
            end
        end
        return false
    end,
    
    -- Отладка
    Debug = function(self, msg)
        if DBM_Scanner and DBM_Scanner.debug then
            DBM_Scanner:Debug("[Модуль "..self.className.."] "..msg)
        end
    end,
    
    -- Вывод сообщения
    Print = function(self, msg)
        if DBM_Scanner then
            DBM_Scanner:Print("[Модуль "..self.className.."] "..msg)
        end
    end
}

-- Функция создания нового модуля класса
function DSTemplate:CreateClassModule(className, customFunctions)
    local module = {}
    
    -- Копируем базовые функции
    for k, v in pairs(self.ClassModule) do
        module[k] = v
    end
    
    -- Добавляем кастомные функции
    if customFunctions then
        for k, v in pairs(customFunctions) do
            module[k] = v
        end
    end
    
    -- Устанавливаем имя класса
    module.className = className
    
    return module
end

-- Экспорт шаблона
DSTemplate:Print("Шаблон модуля класса загружен")