-- ==============================================
-- DBM_Scanner_AI - AI Engine for Rotation Learning
-- ==============================================
local addonName = "DBM_Scanner_AI"

-- Основная таблица ИИ
DBM_Scanner_AI = DBM_Scanner_AI or {}
local DSAI = DBM_Scanner_AI

-- Конфигурация ИИ
DSAI.version = "1.0.0"
DSAI.isTraining = false
DSAI.isLearning = true
DSAI.learningRate = 0.1  -- Скорость обучения
DSAI.explorationRate = 0.3  -- Вероятность исследования (пробовать новые варианты)

-- Базы данных
DSAI.KnowledgeBase = {}  -- Основная база знаний
DSAI.TrainingLog = {}    -- Лог тренировок
DSAI.SpellDatabase = {}  -- Информация о заклинаниях

-- Временные переменные
DSAI.lastDecision = nil
DSAI.lastState = nil
DSAI.decisionHistory = {}
DSAI.performanceMetrics = {}

-- Инициализация ИИ движка
function DSAI:Initialize()
    self:Debug("=== Инициализация ИИ движка ===")
    
    -- Загрузка сохраненных данных
    self:LoadKnowledgeBase()
    
    -- Инициализация базовых структур
    self.KnowledgeBase.classes = self.KnowledgeBase.classes or {}
    self.TrainingLog.sessions = self.TrainingLog.sessions or {}
    
    -- Получение информации об игроке
    self.playerClass = select(2, UnitClass("player"))
    self.playerSpec = GetSpecialization()
    self.playerSpecName = self.playerSpec and select(2, GetSpecializationInfo(self.playerSpec)) or "Unknown"
    
    -- Инициализация для текущего класса
    self:InitializeForClass()
    
    self:Debug("ИИ движок готов. Класс: "..self.playerClass.. ", Спек: "..self.playerSpecName)
end

-- Инициализация для текущего класса
function DSAI:InitializeForClass()
    local classKey = self.playerClass.."_"..self.playerSpecName
    
    if not self.KnowledgeBase.classes[classKey] then
        self.KnowledgeBase.classes[classKey] = {
            created = time(),
            lastModified = time(),
            decisions = {},
            patterns = {},
            successRates = {},
            spellPriorities = {},
            stateActions = {}
        }
        self:Debug("Создана новая база знаний для: "..classKey)
    else
        self:Debug("Загружена существующая база знаний для: "..classKey)
    end
    
    self.currentClassDB = self.KnowledgeBase.classes[classKey]
end

-- Получение решения от ИИ
function DSAI:GetDecision(gameState, rotationModule)
    if not self.isLearning and not self.currentClassDB then
        self:Debug("ИИ не обучен и не в режиме обучения")
        return nil
    end
    
    -- Сохраняем текущее состояние
    self.lastState = self:NormalizeState(gameState)
    
    -- Получаем доступные действия
    local availableActions = self:GetAvailableActions(gameState, rotationModule)
    if not availableActions or #availableActions == 0 then
        self:Debug("Нет доступных действий")
        return nil
    end
    
    -- Выбор действия
    local chosenAction = nil
    
    if self.isTraining then
        -- В режиме тренировки: исследование
        chosenAction = self:ExploreAction(availableActions, gameState)
    else
        -- В боевом режиме: эксплуатация знаний
        chosenAction = self:ExploitAction(availableActions, gameState)
    end
    
    if chosenAction then
        -- Сохраняем решение для оценки
        self.lastDecision = {
            action = chosenAction,
            timestamp = GetTime(),
            state = self.lastState
        }
        
        table.insert(self.decisionHistory, {
            time = GetTime(),
            action = chosenAction,
            state = self.lastState
        })
        
        -- Ограничиваем историю до 100 последних решений
        if #self.decisionHistory > 100 then
            table.remove(self.decisionHistory, 1)
        end
        
        self:Debug("ИИ решение: "..(chosenAction.name or chosenAction.id or "Unknown"))
        return chosenAction
    end
    
    return nil
end

-- Исследование (пробуем новые действия)
function DSAI:ExploreAction(actions, gameState)
    -- Случайное исследование с вероятностью explorationRate
    if math.random() < self.explorationRate then
        local randomIndex = math.random(1, #actions)
        self:Debug("Исследование: случайное действие #"..randomIndex)
        return actions[randomIndex]
    end
    
    -- Иначе используем знания
    return self:ExploitAction(actions, gameState)
end

-- Использование знаний
function DSAI:ExploitAction(actions, gameState)
    -- Получаем "сигнатуру" состояния
    local stateSig = self:GetStateSignature(gameState)
    
    -- Ищем известные решения для этого состояния
    if self.currentClassDB.stateActions[stateSig] then
        local knownActions = self.currentClassDB.stateActions[stateSig]
        
        -- Фильтруем только доступные действия
        local availableKnownActions = {}
        for _, action in ipairs(knownActions) do
            for _, availAction in ipairs(actions) do
                if self:CompareActions(action, availAction) then
                    table.insert(availableKnownActions, action)
                    break
                end
            end
        end
        
        if #availableKnownActions > 0 then
            -- Выбираем действие с наивысшей успешностью
            table.sort(availableKnownActions, function(a, b)
                local rateA = self.currentClassDB.successRates[tostring(a.id)] or 0.5
                local rateB = self.currentClassDB.successRates[tostring(b.id)] or 0.5
                return rateA > rateB
            end)
            
            self:Debug("Использую известное решение ("..#availableKnownActions.." вариантов)")
            return availableKnownActions[1]
        end
    end
    
    -- Если нет известных решений, используем эвристики
    return self:HeuristicChoice(actions, gameState)
end

-- Фильтрация боевых заклинаний
function DSAI:FilterCombatSpells(spells)
    if not spells then return {} end
    
    local combatSpells = {}
    local nonCombatKeywords = {
        "тотем", "дух", "призыв", "воскрешение", "оживление", "ритуал",
        "обряд", "объятья", "сосредоточение", "провидение", "ясновидение",
        "ясночувствие", "яснослышание", "внутреннее", "прозрение"
    }
    
    for _, spell in ipairs(spells) do
        local spellName = spell.name or ""
        local lowerName = string.lower(spellName)
        
        -- Проверяем что это боевое заклинание
        local isCombat = true
        
        -- 1. Проверка по ключевым словам
        for _, keyword in ipairs(nonCombatKeywords) do
            if string.find(lowerName, keyword) then
                isCombat = false
                break
            end
        end
        
        -- 2. Проверка что это не бафф/утилити (кроме важных боевых)
        if isCombat then
            -- Разрешаем важные боевые баффы
            local allowedBuffs = {
                "ярость", "берсерк", "аватара", "кровожадность", "ледяная",
                "огненная", "природная", "тьма", "свет", "аркана"
            }
            
            local isBuff = false
            for _, buff in ipairs(allowedBuffs) do
                if string.find(lowerName, buff) then
                    isBuff = true
                    break
                end
            end
            
            -- Если не важный бафф и нет урона в описании - пропускаем
            if not isBuff then
                local tooltip = self:GetSpellTooltip(spell.id)
                if tooltip and not string.find(string.lower(tooltip), "урон") then
                    isCombat = false
                end
            end
        end
        
        -- 3. Проверка по ID (избегаем телепортов и т.д.)
        if isCombat and spell.id then
            local badSpellIDs = {51005, 3565, 3567, 3561, 3562, 3563, 3566, 32272}
            for _, badID in ipairs(badSpellIDs) do
                if spell.id == badID then
                    isCombat = false
                    break
                end
            end
        end
        
        if isCombat then
            table.insert(combatSpells, spell)
        else
            self:Debug("Фильтр: пропускаем не боевое заклинание: "..spellName)
        end
    end
    
    return combatSpells
end

-- Эвристический выбор (когда нет данных)
function DSAI:HeuristicChoice(actions, gameState)
    -- Простые эвристики для начала
    local scoredActions = {}
    
    for _, action in ipairs(actions) do
        local score = 0
        
        -- Предпочтение мгновенных заклинаний
        local castTime = select(4, GetSpellInfo(action.id or action.name)) or 0
        if castTime == 0 then score = score + 20 end
        
        -- Предпочтение заклинаний без КД
        local start, duration = GetSpellCooldown(action.id or action.name)
        if start == 0 then score = score + 30 end
        
        -- Предпочтение более дорогих заклинаний (обычно сильнее)
        local powerCost = GetSpellPowerCost(action.id or action.name)
        if powerCost and powerCost > 0 then score = score + powerCost end
        
        -- Штраф за длительное применение
        if castTime > 2.5 then score = score - 15 end
        
        table.insert(scoredActions, {action = action, score = score})
    end
    
    -- Сортировка по очкам
    table.sort(scoredActions, function(a, b) return a.score > b.score end)
    
    if #scoredActions > 0 then
        self:Debug("Эвристический выбор: "..scoredActions[1].score.." очков")
        return scoredActions[1].action
    end
    
    -- Последний вариант: первое доступное действие
    return actions[1]
end

-- Оценка результата решения
function DSAI:EvaluateDecision(damageData, healingData, combatTime)
    if not self.lastDecision or not self.lastState then
        self:Debug("Нет решения для оценки")
        return
    end
    
    -- Получаем сигнатуру состояния
    local stateSig = self:GetStateSignature(self.lastState)
    local actionKey = tostring(self.lastDecision.action.id or self.lastDecision.action.name)
    
    -- Инициализация записей если их нет
    if not self.currentClassDB.successRates[actionKey] then
        self.currentClassDB.successRates[actionKey] = 0.5  -- Начальная успешность
    end
    
    if not self.currentClassDB.stateActions[stateSig] then
        self.currentClassDB.stateActions[stateSig] = {}
    end
    
    -- Рассчитываем успешность
    local successScore = 0
    
    -- Учитываем урон
    if damageData and damageData.total > 0 then
        local dps = damageData.total / math.max(combatTime, 1)
        successScore = successScore + math.min(dps / 1000, 1.0)  -- Нормализуем
    end
    
    -- Учитываем выживание
    if not UnitIsDeadOrGhost("player") then
        successScore = successScore + 0.3
    end
    
    -- Учитываем использование ресурсов
    local powerPercent = UnitPower("player") / UnitPowerMax("player")
    if powerPercent > 0.2 then
        successScore = successScore + 0.2
    end
    
    -- Нормализуем оценку 0-1
    successScore = math.min(math.max(successScore, 0), 1)
    
    -- Обновляем успешность (скользящее среднее)
    local currentRate = self.currentClassDB.successRates[actionKey]
    local newRate = currentRate * (1 - self.learningRate) + successScore * self.learningRate
    
    self.currentClassDB.successRates[actionKey] = newRate
    
    -- Добавляем действие в базу для этого состояния
    local exists = false
    for _, action in ipairs(self.currentClassDB.stateActions[stateSig]) do
        if self:CompareActions(action, self.lastDecision.action) then
            exists = true
            break
        end
    end
    
    if not exists then
        table.insert(self.currentClassDB.stateActions[stateSig], self.lastDecision.action)
    end
    
    -- Сохраняем метрики
    table.insert(self.performanceMetrics, {
        time = GetTime(),
        action = self.lastDecision.action,
        successScore = successScore,
        damage = damageData and damageData.total or 0,
        state = stateSig
    })
    
    -- Ограничиваем размер метрик
    if #self.performanceMetrics > 1000 then
        table.remove(self.performanceMetrics, 1)
    end
    
    self:Debug("Оценка решения: "..(successScore*100).."% успешности")
    self.lastDecision = nil
    self.lastState = nil
end

-- Получение доступных действий (ИСПРАВЛЕННАЯ)
function DSAI:GetAvailableActions(gameState, rotationModule)
    local actions = {}
    
    -- Шаг 1: Пробуем получить заклинания из сканера
    if DBM_Scanner_Spells and DBM_Scanner_Spells.SpellsByClass then
        local classSpells = DBM_Scanner_Spells.SpellsByClass[self.playerClass]
        if classSpells then
            for _, spell in ipairs(classSpells) do
                if self:IsSpellReadyForCombat(spell, gameState) then
                    table.insert(actions, spell)
                end
            end
            self:Debug("Из сканера: "..#actions.." заклинаний")
        end
    end
    
    -- Шаг 2: Если сканер пуст, пробуем модуль
    if #actions == 0 and rotationModule and type(rotationModule.GetAvailableSpells) == "function" then
        local moduleSpells = rotationModule:GetAvailableSpells(gameState)
        if moduleSpells then
            for _, spell in ipairs(moduleSpells) do
                if self:IsSpellReadyForCombat(spell, gameState) then
                    table.insert(actions, spell)
                end
            end
        end
        self:Debug("Из модуля: "..#actions.." заклинаний")
    end
    
    -- Шаг 3: Если всё еще пусто, ищем вручную
    if #actions == 0 then
        actions = self:FindBasicSpells(gameState)
        self:Debug("Вручную найдено: "..#actions.." заклинаний")
    end
    
    return actions
end

-- Поиск базовых заклинаний
function DSAI:FindBasicSpells(gameState)
    local spells = {}
    
    -- Ищем заклинания с "удар" в названии
    for i = 1, 500 do
        local name = GetSpellInfo(i)
        if name and (IsSpellKnown(i) or IsPlayerSpell(i)) then
            local lowerName = string.lower(name)
            if string.find(lowerName, "удар") or 
               string.find(lowerName, "стрела") or
               string.find(lowerName, "молния") or
               string.find(lowerName, "огонь") then
                
                if self:IsSpellReadyForCombat({id = i, name = name}, gameState) then
                    table.insert(spells, {id = i, name = name})
                end
            end
        end
    end
    
    return spells
end

-- Упрощенная проверка готовности
function DSAI:IsSpellReadyForCombat(spell, gameState)
    if not spell or not spell.id then return false end
    
    -- Проверка КД
    local start, duration = GetSpellCooldown(spell.id)
    if start > 0 then
        self:Debug(spell.name.." на КД: "..(duration - (GetTime() - start)))
        return false
    end
    
    -- Проверка доступности
    if not IsUsableSpell(spell.id) then
        self:Debug(spell.name.." недоступно")
        return false
    end
    
    -- Проверка дистанции
    if UnitExists("target") then
        local inRange = IsSpellInRange(spell.name or spell.id, "target")
        if inRange == 0 then
            self:Debug(spell.name.." вне дистанции")
            return false
        end
    end
    
    return true
end

-- Обновленная функция выбора действия с обучением
function DSAI:ExploreAction(actions, gameState)
    -- В режиме обучения чаще исследуем
    local explorationChance = self.isTraining and 0.5 or self.explorationRate
    
    if math.random() < explorationChance then
        -- ИССЛЕДОВАНИЕ: пробуем случайное действие
        local randomIndex = math.random(1, #actions)
        local chosenAction = actions[randomIndex]
        self:Debug("ИССЛЕДОВАНИЕ: случайное действие #"..randomIndex.." - "..chosenAction.name)
        return chosenAction
    else
        -- ЭКСПЛУАТАЦИЯ: используем лучшие знания
        return self:ExploitBestAction(actions, gameState)
    end
end

-- Выбор лучшего действия на основе знаний
function DSAI:ExploitBestAction(actions, gameState)
    if not actions or #actions == 0 then return nil end
    
    -- Если есть знания, используем их
    local stateSig = self:GetStateSignature(gameState)
    
    if self.currentClassDB.stateActions and self.currentClassDB.stateActions[stateSig] then
        local knownActions = self.currentClassDB.stateActions[stateSig]
        
        -- Ищем лучшее действие из известных
        local bestAction = nil
        local bestScore = -9999
        
        for _, knownAction in ipairs(knownActions) do
            for _, availableAction in ipairs(actions) do
                if self:CompareActions(knownAction, availableAction) then
                    local actionKey = tostring(availableAction.id or availableAction.name)
                    local successRate = self.currentClassDB.successRates[actionKey] or 0.5
                    local score = successRate * 100
                    
                    -- Бонус за редкость использования (чтобы не залипал на одном)
                    local usageCount = self.actionUsage[actionKey] or 0
                    score = score - (usageCount * 0.1)  -- Штраф за частое использование
                    
                    if score > bestScore then
                        bestScore = score
                        bestAction = availableAction
                    end
                end
            end
        end
        
        if bestAction then
            self:Debug("ИСПОЛЬЗУЮ ЗНАНИЯ: "..bestAction.name.." (оценка: "..string.format("%.1f", bestScore)..")")
            return bestAction
        end
    end
    
    -- Если знаний нет, используем эвристики
    return self:HeuristicChoice(actions, gameState)
end

-- Улучшенная эвристика выбора
function DSAI:HeuristicChoice(actions, gameState)
    local scoredActions = {}
    
    for _, action in ipairs(actions) do
        local score = 0
        
        -- Базовые эвристики
        local castTime = select(4, GetSpellInfo(action.id)) or 0
        
        -- Предпочтение мгновенных заклинаний
        if castTime == 0 then score = score + 30 end
        
        -- Предпочтение заклинаний без КД
        local start, duration = GetSpellCooldown(action.id)
        if start == 0 then score = score + 20 end
        
        -- Предпочтение "ударных" заклинаний
        local lowerName = string.lower(action.name or "")
        if string.find(lowerName, "удар") then score = score + 25 end
        if string.find(lowerName, "молния") then score = score + 20 end
        if string.find(lowerName, "огонь") then score = score + 15 end
        
        -- Штраф за длительные касты в ближнем бою
        if gameState.target.distance == 0 and castTime > 2.0 then
            score = score - 20
        end
        
        -- Штраф за частые использования
        local actionKey = tostring(action.id or action.name)
        local usageCount = self.actionUsage[actionKey] or 0
        score = score - (usageCount * 2)
        
        table.insert(scoredActions, {action = action, score = score})
    end
    
    -- Сортировка по очкам
    table.sort(scoredActions, function(a, b) return a.score > b.score end)
    
    if #scoredActions > 0 then
        local chosen = scoredActions[1]
        local usageCount = self.actionUsage[tostring(chosen.action.id or chosen.action.name)] or 0
        self:Debug("ЭВРИСТИКА: "..chosen.action.name.." ("..chosen.score.." очков, использовано: "..usageCount.." раз)")
        return chosen.action
    end
    
    return actions[1]
end

-- Добавьте инициализацию счетчика использований в InitializeForClass:
function DSAI:InitializeForClass()
    local classKey = self.playerClass.."_"..self.playerSpecName
    
    if not self.KnowledgeBase.classes[classKey] then
        self.KnowledgeBase.classes[classKey] = {
            created = time(),
            lastModified = time(),
            decisions = {},
            patterns = {},
            successRates = {},
            spellPriorities = {},
            stateActions = {}
        }
        self:Debug("Создана новая база знаний для: "..classKey)
    else
        self:Debug("Загружена существующая база знаний для: "..classKey)
    end
    
    self.currentClassDB = self.KnowledgeBase.classes[classKey]
    self.actionUsage = {}  -- Счетчик использований для каждого действия
end

-- Обновляйте счетчик при выборе действия:
function DSAI:GetDecision(gameState, rotationModule)
    if not self.isLearning and not self.currentClassDB then
        self:Debug("ИИ не обучен и не в режиме обучения")
        return nil
    end
    
    -- Сохраняем текущее состояние
    self.lastState = self:NormalizeState(gameState)
    
    -- Получаем доступные действия
    local availableActions = self:GetAvailableActions(gameState, rotationModule)
    if not availableActions or #availableActions == 0 then
        self:Debug("Нет доступных действий")
        return nil
    end
    
    -- Выбор действия
    local chosenAction = nil
    
    if self.isTraining then
        -- В режиме тренировки: больше исследований
        chosenAction = self:ExploreAction(availableActions, gameState)
    else
        -- В боевом режиме
        chosenAction = self:ExploreAction(availableActions, gameState)
    end
    
    if chosenAction then
        -- Увеличиваем счетчик использований
        local actionKey = tostring(chosenAction.id or chosenAction.name)
        self.actionUsage[actionKey] = (self.actionUsage[actionKey] or 0) + 1
        
        -- Сохраняем решение для оценки
        self.lastDecision = {
            action = chosenAction,
            timestamp = GetTime(),
            state = self.lastState,
            actionKey = actionKey
        }
        
        self:Debug("ИИ решение: "..chosenAction.name.." (использовано: "..self.actionUsage[actionKey].." раз)")
        return chosenAction
    end
    
    return nil
end

-- Упрощенная оценка результата
function DSAI:EvaluateSimple()
    if not self.lastDecision then return end
    
    -- Простая оценка: +1 если цель жива и мы в бою
    local score = 0
    
    if UnitAffectingCombat("player") and UnitExists("target") and not UnitIsDeadOrGhost("target") then
        score = 1
    end
    
    -- Если цель умерла - отличный результат
    if UnitIsDeadOrGhost("target") then
        score = 2
    end
    
    -- Если игрок умер - плохо
    if UnitIsDeadOrGhost("player") then
        score = -1
    end
    
    -- Обновляем успешность
    local actionKey = self.lastDecision.actionKey
    if not self.currentClassDB.successRates[actionKey] then
        self.currentClassDB.successRates[actionKey] = 0.5
    end
    
    local currentRate = self.currentClassDB.successRates[actionKey]
    local newRate = currentRate * 0.9 + (score / 2) * 0.1  -- Скользящее среднее
    self.currentClassDB.successRates[actionKey] = math.max(0, math.min(1, newRate))
    
    -- Добавляем в историю состояний
    local stateSig = self:GetStateSignature(self.lastState)
    if not self.currentClassDB.stateActions[stateSig] then
        self.currentClassDB.stateActions[stateSig] = {}
    end
    
    -- Добавляем действие если его еще нет
    local exists = false
    for _, action in ipairs(self.currentClassDB.stateActions[stateSig]) do
        if self:CompareActions(action, self.lastDecision.action) then
            exists = true
            break
        end
    end
    
    if not exists then
        table.insert(self.currentClassDB.stateActions[stateSig], self.lastDecision.action)
    end
    
    self:Debug("Оценка: "..actionKey.." = "..score.." (успешность: "..string.format("%.1f%%", self.currentClassDB.successRates[actionKey]*100)..")")
    
    self.lastDecision = nil
    self.lastState = nil
end

function DSAI:PrintLearningStatus()
    self:Print("=== СТАТУС ОБУЧЕНИЯ ===")
    self:Print("Режим обучения: "..(self.isLearning and "|cFF00FF00ВКЛ|r" or "|cFFFF0000ВЫКЛ|r"))
    self:Print("Режим тренировки: "..(self.isTraining and "|cFF00FF00ВКЛ|r" or "|cFFFF0000ВЫКЛ|r"))
    
    if self.currentClassDB then
        local learnedStates = 0
        if self.currentClassDB.stateActions then
            learnedStates = table.count(self.currentClassDB.stateActions)
        end
        
        local learnedSpells = 0
        if self.currentClassDB.successRates then
            learnedSpells = table.count(self.currentClassDB.successRates)
        end
        
        self:Print("Выучено состояний: "..learnedStates)
        self:Print("Выучено заклинаний: "..learnedSpells)
        
        -- Показываем топ-5 заклинаний
        if learnedSpells > 0 then
            self:Print("=== ТОП-5 заклинаний ===")
            local spells = {}
            for actionKey, rate in pairs(self.currentClassDB.successRates) do
                table.insert(spells, {key = actionKey, rate = rate})
            end
            
            table.sort(spells, function(a, b) return a.rate > b.rate end)
            
            for i = 1, math.min(5, #spells) do
                self:Print(i..". "..spells[i].key..": "..string.format("%.1f%%", spells[i].rate*100))
            end
        end
    end
end

-- Проверка готовности заклинания для боя
function DSAI:IsSpellReadyForCombat(spell, gameState)
    if not spell then return false end
    
    -- Проверка КД
    local start, duration = GetSpellCooldown(spell.id or spell.name)
    if start > 0 then return false end
    
    -- Проверка ресурсов
    if not IsUsableSpell(spell.id or spell.name) then return false end
    
    -- Проверка что заклинание не пассивное
    if spell.isPassive then return false end
    
    -- Проверка что это не заклинание с длительным кастом в ближнем бою
    if gameState.target.distance == 0 and spell.castTime and spell.castTime > 1.5 then
        return false  -- В ближнем бою избегаем долгих кастов
    end
    
    return true
end

-- Сканирование доступных заклинаний
function DSAI:ScanUsableSpells(gameState)
    local usableSpells = {}
    
    -- Проверяем все известные заклинания
    for i = 1, 300000 do
        local name, _, _, castTime, _, _, id = GetSpellInfo(i)
        if name and IsSpellKnown(i) and not IsPassiveSpell(i) then
            -- Проверяем можно ли использовать
            if IsUsableSpell(i) then
                local start, duration = GetSpellCooldown(i)
                if start == 0 then  -- Нет КД
                    local spellData = {
                        id = i,
                        name = name,
                        castTime = castTime,
                        isUsable = true
                    }
                    
                    -- Проверяем дистанцию если есть цель
                    if UnitExists("target") then
                        local inRange = IsSpellInRange(name, "target")
                        spellData.inRange = (inRange == 1)
                    else
                        spellData.inRange = true
                    end
                    
                    table.insert(usableSpells, spellData)
                end
            end
        end
    end
    
    return usableSpells
end

-- Проверка можно ли использовать заклинание
function DSAI:IsSpellUsable(spell)
    if type(spell) == "table" then
        if spell.id then
            return IsUsableSpell(spell.id)
        elseif spell.name then
            return IsUsableSpell(spell.name)
        end
    elseif type(spell) == "number" then
        return IsUsableSpell(spell)
    elseif type(spell) == "string" then
        return IsUsableSpell(spell)
    end
    
    return false
end

-- Нормализация состояния для сравнения
function DSAI:NormalizeState(gameState)
    if not gameState then return "" end
    
    local normalized = {
        -- Дискретизируем проценты
        health = math.floor(gameState.health.percent / 10) * 10,  -- 0, 10, 20, ..., 100
        power = math.floor(gameState.power.current / math.max(gameState.power.max, 1) * 100 / 10) * 10,
        
        -- Цель
        targetExists = gameState.target.exists and 1 or 0,
        targetHealth = gameState.target.exists and math.floor(gameState.target.health / 10) * 10 or 0,
        targetDistance = gameState.target.exists and math.floor(gameState.target.distance / 5) * 5 or 999,
        
        -- Бой
        inCombat = gameState.inCombat and 1 or 0,
        isCasting = gameState.isCasting and 1 or 0,
        
        -- Группа
        groupSize = math.min(gameState.groupSize or 1, 5)  -- 1-5 для нормализации
    }
    
    -- Добавляем класс-специфичные данные
    if gameState.classSpecific then
        for key, value in pairs(gameState.classSpecific) do
            if type(value) == "number" then
                normalized[key] = math.floor(value)
            else
                normalized[key] = tostring(value)
            end
        end
    end
    
    -- Создаем строковую сигнатуру
    local parts = {}
    for key, value in pairs(normalized) do
        table.insert(parts, key..":"..tostring(value))
    end
    
    table.sort(parts)  -- Для консистентности
    return table.concat(parts, "|")
end

-- Получение сигнатуры состояния
function DSAI:GetStateSignature(gameState)
    return self:NormalizeState(gameState)
end

-- Сравнение действий
function DSAI:CompareActions(a, b)
    if a.id and b.id then
        return a.id == b.id
    elseif a.name and b.name then
        return a.name == b.name
    end
    
    return false
end

-- Режим тренировки
function DSAI:StartTraining(durationMinutes)
    self.isTraining = true
    self.isLearning = true
    self.explorationRate = 0.7  -- Высокое исследование в тренировке
    
    local duration = (durationMinutes or 30) * 60  -- В секундах
    local endTime = GetTime() + duration
    
    self.trainingSession = {
        startTime = GetTime(),
        endTime = endTime,
        duration = duration,
        decisionsMade = 0,
        damageDealt = 0,
        spellsUsed = {}
    }
    
    self:Print("Начата тренировка на "..(durationMinutes or 30).." минут")
    self:Print("Режим исследования: "..(self.explorationRate*100).."%")
    
    -- Запуск таймера окончания тренировки
    C_Timer.After(duration, function()
        self:EndTraining()
    end)
end

function DSAI:EndTraining()
    if not self.isTraining then return end
    
    self.isTraining = false
    self.explorationRate = 0.3  -- Возвращаем нормальный уровень
    
    -- Сохранение сессии
    table.insert(self.TrainingLog.sessions, self.trainingSession)
    
    -- Анализ результатов
    self:AnalyzeTrainingSession()
    
    self:Print("Тренировка завершена")
    self:Print("Решений принято: "..self.trainingSession.decisionsMade)
    self:Print("Изучено состояний: "..(self.currentClassDB.stateActions and table.count(self.currentClassDB.stateActions) or 0))
    
    self.trainingSession = nil
    
    -- Сохранение знаний
    self:SaveKnowledgeBase()
end

-- Анализ сессии тренировки
function DSAI:AnalyzeTrainingSession()
    if not self.trainingSession then return end
    
    -- Анализ наиболее успешных действий
    local actionSuccess = {}
    
    for _, metric in ipairs(self.performanceMetrics) do
        if metric.time >= self.trainingSession.startTime then
            local actionKey = tostring(metric.action.id or metric.action.name)
            if not actionSuccess[actionKey] then
                actionSuccess[actionKey] = {total = 0, count = 0}
            end
            
            actionSuccess[actionKey].total = actionSuccess[actionKey].total + metric.successScore
            actionSuccess[actionKey].count = actionSuccess[actionKey].count + 1
        end
    end
    
    -- Вывод лучших действий
    local bestActions = {}
    for actionKey, data in pairs(actionSuccess) do
        local avgSuccess = data.total / data.count
        table.insert(bestActions, {action = actionKey, success = avgSuccess, count = data.count})
    end
    
    table.sort(bestActions, function(a, b) return a.success > b.success end)
    
    self:Print("=== Лучшие действия тренировки ===")
    for i = 1, math.min(5, #bestActions) do
        local action = bestActions[i]
        self:Print(string.format("%d. %s: %.1f%% (%d раз)", 
            i, action.action, action.success * 100, action.count))
    end
end

-- Проверка обученности ИИ
function DSAI:IsTrained()
    if not self.currentClassDB then return false end
    
    local decisionCount = 0
    if self.currentClassDB.stateActions then
        for _, actions in pairs(self.currentClassDB.stateActions) do
            decisionCount = decisionCount + #actions
        end
    end
    
    -- Считаем обученным если есть хотя бы 50 записей
    return decisionCount >= 50
end

-- Сохранение базы знаний
function DSAI:SaveKnowledgeBase()
    -- В реальной реализации здесь было бы сохранение в файл
    -- Для простоты используем глобальную переменную
    _G["DBM_Scanner_AI_SaveData"] = self.KnowledgeBase
    self:Debug("База знаний сохранена ("..table.count(self.KnowledgeBase.classes or {}).." классов)")
end

-- Загрузка базы знаний
function DSAI:LoadKnowledgeBase()
    if _G["DBM_Scanner_AI_SaveData"] then
        self.KnowledgeBase = _G["DBM_Scanner_AI_SaveData"]
        self:Debug("База знаний загружена")
    else
        self.KnowledgeBase = {classes = {}}
        self:Debug("Создана новая база знаний")
    end
end

-- Интеграция с Details! для сбора данных
function DSAI:HookDetails()
    if not Details then
        self:Debug("Аддон Details! не найден")
        return
    end
    
    -- Хук для сбора данных об уроне
    local originalDamageFunction = Details.parser_functions["SPELL_DAMAGE"]
    Details.parser_functions["SPELL_DAMAGE"] = function(...)
        local ret = originalDamageFunction(...)
        
        -- Собираем данные об уроне для оценки
        if DSAI.lastDecision then
            -- Здесь будет анализ данных Details!
            -- Это упрощенная версия
        end
        
        return ret
    end
    
    self:Debug("Интеграция с Details! установлена")
end

-- Вспомогательные функции
function table.count(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

-- Отладочные функции
function DSAI:Debug(msg)
    if DBM_Scanner and DBM_Scanner.debug then
        DBM_Scanner:Debug("[ИИ] "..msg)
    end
end

function DSAI:Print(msg)
    if DBM_Scanner then
        DBM_Scanner:Print("[ИИ] "..msg)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFDBM_Scanner ИИ:|r "..msg)
    end
end

function DSAI:PrintStatus()
    self:Print("=== Статус ИИ движка ===")
    self:Print("Обучен: "..(self:IsTrained() and "|cFF00FF00Да|r" or "|cFFFF0000Нет|r"))
    self:Print("Режим обучения: "..(self.isLearning and "|cFF00FF00ВКЛ|r" or "|cFFFF0000ВЫКЛ|r"))
    self:Print("Режим тренировки: "..(self.isTraining and "|cFF00FF00ВКЛ|r" or "|cFFFF0000ВЫКЛ|r"))
    
    if self.currentClassDB then
        local stateCount = table.count(self.currentClassDB.stateActions or {})
        local decisionCount = 0
        for _, actions in pairs(self.currentClassDB.stateActions or {}) do
            decisionCount = decisionCount + #actions
        end
        
        self:Print("Знаний: "..stateCount.." состояний, "..decisionCount.." решений")
        self:Print("Успешность: "..string.format("%.1f%%", self:GetAverageSuccess() * 100))
    end
end

function DSAI:GetAverageSuccess()
    if not self.currentClassDB or not self.currentClassDB.successRates then
        return 0.5
    end
    
    local total = 0
    local count = 0
    
    for _, rate in pairs(self.currentClassDB.successRates) do
        total = total + rate
        count = count + 1
    end
    
    return count > 0 and (total / count) or 0.5
end

-- Автоматическая регистрация
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(2, function()
            if DBM_Scanner then
                DSAI:Initialize()
                DSAI:HookDetails()
            end
        end)
    end
end)

DSAI:Print("ИИ движок загружен. Ожидание инициализации...")