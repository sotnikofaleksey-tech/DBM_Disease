-- ==============================================
-- DBM_Scanner_Shaman - Shaman Enhancement Module
-- ==============================================
local addonName = "DBM_Scanner_Shaman"

-- Создание модуля на основе шаблона
DBM_Scanner_Shaman = DBM_Scanner_Template:CreateClassModule("SHAMAN", {
    -- === КЛАСС-СПЕЦИФИЧНЫЕ ФУНКЦИИ ===
    
    -- Переопределение инициализации
    Initialize = function(self)
        -- Вызов родительской инициализации
        DBM_Scanner_Template.ClassModule.Initialize(self)
        
        self:Debug("Инициализация модуля Шамана (Усиление)")
        
        -- Специфичные для шамана данные
        self.maelstrom = 0
        self.flametongue = false
        self.stormstrike = false
        
        -- Инициализация специфичных заклинаний
        self:InitShamanSpells()
        
        -- Построение ротации для усиления
        self:BuildEnhancementRotation()
        
        return true
    end,
    
    -- Инициализация заклинаний шамана
    InitShamanSpells = function(self)
        -- Ключевые заклинания усиления (примерные ID для 7.3.5)
        self.keySpells = {
            stormstrike = {name = "Удар бури", id = 17364},
            lava_lash = {name = "Язык пламени", id = 60103},
            crash_lightning = {name = "Сокрушающая молния", id = 187874},
            flametongue = {name = "Язык пламени", id = 193796},
            frostbrand = {name = "Ледяное клеймо", id = 196834},
            rockbiter = {name = "Камнедробитель", id = 193786},
            landslide = {name = "Земляная лавина", id = 197992},
            feral_spirit = {name = "Дух дикого зверя", id = 51533},
            doom_winds = {name = "Ветра рока", id = 204945},
            sundering = {name = "Раскалывание", id = 197214}
        }
        
        -- AOE заклинания
        self.aoeSpells = {
            crash_lightning = true,
            sundering = true
        }
        
        -- DOT заклинания
        self.dotSpells = {
            flametongue = true,
            frostbrand = true
        }
    end,
    
    -- Построение ротации для усиления
    BuildEnhancementRotation = function(self)
        self:Debug("Построение ротации Усиления...")
        
        -- Приоритетная ротация для усиления
        self.priorityRotation = {
            -- 1. Кулдауны
            {spell = "doom_winds", condition = function() return self:IsSpellReady("doom_winds") end, priority = 100},
            {spell = "feral_spirit", condition = function() return self:IsSpellReady("feral_spirit") end, priority = 90},
            
            -- 2. Поддержание DOTов
            {spell = "flametongue", condition = function() return not self:TargetHasDebuff("flametongue") end, priority = 80},
            {spell = "frostbrand", condition = function() return not self:TargetHasDebuff("frostbrand") end, priority = 70},
            
            -- 3. Основные атаки
            {spell = "stormstrike", condition = function() return self:IsSpellReady("stormstrike") end, priority = 60},
            {spell = "lava_lash", condition = function() return self.maelstrom >= 40 end, priority = 50},
            
            -- 4. Генерация маэльстрома
            {spell = "rockbiter", condition = function() return self.maelstrom < 100 end, priority = 40},
            {spell = "crash_lightning", condition = function() return self:GetNumEnemies() >= 2 end, priority = 35},
            
            -- 5. Заполнение
            {spell = "landslide", condition = function() return true end, priority = 30},
            {spell = "sundering", condition = function() return self:GetNumEnemies() >= 3 end, priority = 25}
        }
        
        self:Debug("Построена приоритетная ротация из "..#self.priorityRotation.." элементов")
    end,
    
    -- Переопределение выбора заклинания
    ChooseSpell = function(self, availableSpells, gameState)
        -- Обновление состояния
        self:UpdateShamanState(gameState)
        
        -- Проверка приоритетной ротации
        for _, prioritySpell in ipairs(self.priorityRotation) do
            local spellData = self.keySpells[prioritySpell.spell]
            if spellData then
                -- Проверка условия
                if prioritySpell.condition() then
                    -- Проверка можно ли использовать
                    if self:IsSpellUsable(spellData, gameState) then
                        return spellData
                    end
                end
            end
        end
        
        -- Если ничего из приоритетной ротации не доступно, используем базовую логику
        return DBM_Scanner_Template.ClassModule.ChooseSpell(self, availableSpells, gameState)
    end,
    
    -- Обновление состояния шамана
    UpdateShamanState = function(self, gameState)
        -- Обновление маэльстрома
        self.maelstrom = UnitPower("player", 11) or 0  -- 11 = MAELSTROM_POWER
        
        -- Проверка баффов
        self.flametongue = self:HasBuff("Язык пламени")
        self.stormstrike = self:HasBuff("Удар бури")
        
        -- Обновление количества врагов
        self.numEnemies = self:GetNumEnemies()
        
        -- Обновление общего состояния
        self:UpdateClassState()
    end,
    
    -- Получение количества врагов вокруг
    GetNumEnemies = function(self)
        local count = 0
        local range = 10  -- Дистанция для AOE
        
        -- Простой подсчет целей вокруг
        -- В реальной реализации нужен более точный метод
        if UnitExists("target") then
            count = 1
        end
        
        -- Можно добавить проверку через GetNumGroupMembers и т.д.
        return count
    end,
    
    -- Проверка готовности заклинания
    IsSpellReady = function(self, spellKey)
        local spellData = self.keySpells[spellKey]
        if not spellData then return false end
        
        local start, duration = GetSpellCooldown(spellData.id or spellData.name)
        return start == 0
    end,
    
    -- Переопределение получения вторничных ресурсов
    GetSecondaryResources = function(self)
        return {
            maelstrom = self.maelstrom,
            maelstromMax = 100,
            maelstromPercent = self.maelstrom / 100 * 100
        }
    end,
    
    -- Переопределение класс-специфичного состояния
    GetClassSpecificState = function(self)
        return {
            maelstrom = self.maelstrom,
            hasFlametongue = self.flametongue,
            hasStormstrike = self.stormstrike,
            numEnemies = self.numEnemies,
            isEnhancement = (self.specID == 2)  -- 2 = Enhancement
        }
    end,
    
    -- Класс-специфичные условия
    ClassSpecificConditions = function(self, gameState)
        -- Для усиления проверяем наличие оружия в обеих руках
        local hasMainHand = GetInventoryItemID("player", 16) ~= nil
        local hasOffHand = GetInventoryItemID("player", 17) ~= nil
        
        if not hasMainHand then
            self:Debug("Нет оружия в основной руке")
            return false
        end
        
        return true
    end,
    
    -- Условия для конкретного заклинания
    SpellSpecificConditions = function(self, spell, gameState)
        local spellName = spell.name or ""
        
        -- Проверки для специфичных заклинаний
        if string.find(spellName, "Язык пламени") then
            -- Для языка пламени проверяем есть ли уже бафф
            if self:HasBuff("Язык пламени") then
                local _, _, _, _, duration, expires = self:GetBuffInfo("Язык пламени")
                if expires - GetTime() > 10 then  -- Если больше 10 секунд осталось
                    return false
                end
            end
        end
        
        if string.find(spellName, "Сокрушающая молния") then
            -- Для AOE проверяем количество врагов
            return self.numEnemies >= 2
        end
        
        return true
    end,
    
    -- Получение информации о баффе
    GetBuffInfo = function(self, buffName)
        for i = 1, 40 do
            local name, _, _, _, duration, expires, _, _, _, spellId = UnitBuff("player", i)
            if not name then break end
            if name == buffName then
                return true, duration, expires, spellId
            end
        end
        return false, 0, 0, 0
    end,
    
    -- Получение времени до спадения DOTа
    GetDotRemainingTime = function(self, dotName, unit)
        unit = unit or "target"
        
        for i = 1, 40 do
            local name, _, _, _, duration, expires = UnitDebuff(unit, i)
            if not name then break end
            if name == dotName then
                return expires - GetTime()
            end
        end
        
        return 0
    end
})

-- Регистрация модуля в ядре
if DBM_Scanner then
    DBM_Scanner:RegisterModule("SHAMAN", DBM_Scanner_Shaman)
    DBM_Scanner_Shaman:Debug("Модуль Шамана зарегистрирован в ядре")
end

DBM_Scanner_Shaman:Print("Модуль Шамана (Усиление) загружен")