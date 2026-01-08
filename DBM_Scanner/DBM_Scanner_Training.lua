-- ==============================================
-- DBM_Scanner_Training - Training Mode Module
-- ==============================================
local addonName = "DBM_Scanner_Training"

-- Основная таблица модуля
DBM_Scanner_Training = DBM_Scanner_Training or {}
local DST = DBM_Scanner_Training

-- Конфигурация
DST.version = "1.0.0"
DST.isTraining = false
DST.trainingSession = nil
DST.trainingTarget = nil

-- Статистика тренировки
DST.TrainingStats = {
    sessions = {},
    totalDamage = 0,
    totalTime = 0,
    bestDPS = 0,
    spellUsage = {}
}

-- Инициализация модуля
function DST:Initialize()
    self:Debug("=== Инициализация режима тренировки ===")
    
    -- Создание интерфейса тренировки
    self:CreateTrainingUI()
    
    -- Загрузка статистики
    self:LoadStats()
    
    self:Debug("Режим тренировки готов")
end

-- Создание интерфейса тренировки
function DST:CreateTrainingUI()
    -- Основной фрейм тренировки
    self.trainingFrame = CreateFrame("Frame", "DBMScannerTrainingFrame", UIParent)
    self.trainingFrame:SetSize(300, 150)
    self.trainingFrame:SetPoint("CENTER", 0, 200)
    self.trainingFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.trainingFrame:SetBackdropColor(0, 0, 0, 0.9)
    self.trainingFrame:Hide()
    
    -- Заголовок
    self.trainingFrame.title = self.trainingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.trainingFrame.title:SetPoint("TOP", 0, -10)
    self.trainingFrame.title:SetText("|cFF00FFFFDBM Scanner - Тренировка|r")
    
    -- Таймер
    self.trainingFrame.timer = self.trainingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.trainingFrame.timer:SetPoint("TOP", 0, -30)
    self.trainingFrame.timer:SetText("Время: 00:00")
    
    -- DPS метка
    self.trainingFrame.dps = self.trainingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.trainingFrame.dps:SetPoint("TOP", 0, -50)
    self.trainingFrame.dps:SetText("DPS: 0")
    
    -- Использование заклинаний
    self.trainingFrame.spells = self.trainingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.trainingFrame.spells:SetPoint("TOP", 0, -70)
    self.trainingFrame.spells:SetText("Заклинаний: 0")
    
    -- Кнопка остановки
    self.trainingFrame.stopButton = CreateFrame("Button", nil, self.trainingFrame, "UIPanelButtonTemplate")
    self.trainingFrame.stopButton:SetSize(100, 25)
    self.trainingFrame.stopButton:SetPoint("BOTTOM", 0, 15)
    self.trainingFrame.stopButton:SetText("Остановить")
    self.trainingFrame.stopButton:SetScript("OnClick", function()
        self:StopTraining()
    end)
    
    -- Фрейм для авто-таргета
    self.autoTargetFrame = CreateFrame("Frame")
    self.autoTargetFrame.lastTargetCheck = 0
end

-- Начало тренировки
function DST:StartTraining(durationMinutes, trainingType)
    if self.isTraining then
        self:Print("Тренировка уже идет")
        return
    end
    
    -- Параметры тренировки
    durationMinutes = durationMinutes or 30
    trainingType = trainingType or "dummy"
    
    -- Поиск тренировочного манекена
    local dummyFound = self:FindTrainingDummy()
    if not dummyFound then
        self:Print("|cFFFF0000Не найден тренировочный манекен!|r")
        self:Print("Найдите манекен для начала тренировки")
        return
    end
    
    -- Настройка сессии
    self.isTraining = true
    self.trainingType = trainingType
    self.trainingTarget = dummyFound
    
    self.trainingSession = {
        startTime = GetTime(),
        endTime = GetTime() + (durationMinutes * 60),
        duration = durationMinutes * 60,
        trainingType = trainingType,
        damageDealt = 0,
        healingDone = 0,
        spellsCast = 0,
        spellUsage = {},
        sessionData = {}
    }
    
    -- Настройка ИИ для тренировки
    function DST:StartTraining(durationMinutes, trainingType)
    if self.isTraining then
        self:Print("Тренировка уже идет")
        return
    end
    
    -- НАСТРОЙКА ИИ ДЛЯ ТРЕНИРОВКИ
    if DBM_Scanner_AI then
        DBM_Scanner_AI.isTraining = true
        DBM_Scanner_AI.isLearning = true
        DBM_Scanner_AI.explorationRate = 0.7  -- Высокое исследование
        DBM_Scanner_AI:Debug("РЕЖИМ ТРЕНИРОВКИ АКТИВИРОВАН")
    end
    
    -- ВКЛЮЧАЕМ РОТАЦИЮ
    if DBM_Scanner then
        DBM_Scanner.enabled = true
        DBM_Scanner:Print("Ротация включена для тренировки")
    end
    
    -- Включение авто-таргета
    self:EnableAutoTarget()
    
    -- Показ интерфейса
    self.trainingFrame:Show()
    
    -- Запуск основного цикла
    self:StartTrainingLoop()
    
    self:Print("Тренировка начата на "..durationMinutes.." минут")
    self:Print("Цель: "..(self.trainingTarget or "Неизвестно"))
    
    -- Запуск таймера окончания
    C_Timer.After(durationMinutes * 60, function()
        if self.isTraining then
            self:StopTraining()
        end
    end)
end

-- Остановка тренировки
function DST:StopTraining()
    if not self.isTraining then return end
    
    self.isTraining = false
    
    -- Выключение авто-таргета
    self:DisableAutoTarget()
    
    -- Сбор финальной статистики
    self:CollectFinalStats()
    
    -- Анализ результатов
    self:AnalyzeTrainingResults()
    
    -- Сохранение сессии
    self:SaveTrainingSession()
    
    -- Возврат ИИ в нормальный режим
    if DBM_Scanner_AI then
        DBM_Scanner_AI.isTraining = false
        DBM_Scanner_AI.explorationRate = 0.3
        DBM_Scanner_AI:Debug("Режим тренировки завершен")
    end
    
    -- Скрытие интерфейса
    self.trainingFrame:Hide()
    
    self:Print("Тренировка завершена")
    self:Print("Длительность: "..string.format("%.1f", (GetTime() - self.trainingSession.startTime) / 60).." минут")
    self:Print("Общий урон: "..self.trainingSession.damageDealt)
    self:Print("DPS: "..string.format("%.1f", self.trainingSession.averageDPS or 0))
    
    self.trainingSession = nil
    self.trainingTarget = nil
end

-- Поиск тренировочного манекена
function DST:FindTrainingDummy()
    local dummies = {
        "Тренировочный манекен",
        "Training Dummy",
        "Манекен",
        "Dummy",
        "Макет",
        "Мишень"
    }
    
    -- Поиск по имени
    for i = 1, 100 do
        local name = UnitName("party"..i) or UnitName("raid"..i)
        if name then
            for _, dummyName in ipairs(dummies) do
                if string.find(name, dummyName) then
                    return name
                end
            end
        end
    end
    
    -- Поиск в мире (ограниченный радиус)
    local units = { "target", "focus", "mouseover" }
    for _, unit in ipairs(units) do
        if UnitExists(unit) then
            local name = UnitName(unit)
            for _, dummyName in ipairs(dummies) do
                if string.find(name, dummyName) then
                    return name
                end
            end
        end
    end
    
    return nil
end

-- Включение авто-таргета
function DST:EnableAutoTarget()
    self.autoTargetFrame:SetScript("OnUpdate", function(self, elapsed)
        DST.autoTargetFrame.lastTargetCheck = DST.autoTargetFrame.lastTargetCheck + elapsed
        
        if DST.autoTargetFrame.lastTargetCheck >= 1.0 then  -- Проверка каждую секунду
            DST.autoTargetFrame.lastTargetCheck = 0
            
            -- Если нет цели или цель мертва, ищем манекен
            if not UnitExists("target") or UnitIsDeadOrGhost("target") then
                if DST.trainingTarget then
                    -- Пытаемся выбрать цель по имени
                    TargetUnit(DST.trainingTarget)
                else
                    -- Поиск нового манекена
                    local dummy = DST:FindTrainingDummy()
                    if dummy then
                        DST.trainingTarget = dummy
                        TargetUnit(dummy)
                    end
                end
            end
            
            -- Авто-атака если не в бою
            if UnitExists("target") and not UnitAffectingCombat("player") then
                AttackTarget()
            end
        end
    end)
end

-- Выключение авто-таргета
function DST:DisableAutoTarget()
    self.autoTargetFrame:SetScript("OnUpdate", nil)
    
    -- Остановка авто-атаки
    if UnitAffectingCombat("player") then
        StopAttack()
    end
end

-- Основной цикл тренировки
function DST:StartTrainingLoop()
    self.trainingFrame.updateFrame = CreateFrame("Frame")
    self.trainingFrame.updateFrame.lastUpdate = 0
    
    self.trainingFrame.updateFrame:SetScript("OnUpdate", function(self, elapsed)
        DST.trainingFrame.updateFrame.lastUpdate = DST.trainingFrame.updateFrame.lastUpdate + elapsed
        
        if DST.trainingFrame.updateFrame.lastUpdate >= 0.5 then  -- Обновление каждые 0.5 сек
            DST:UpdateTrainingUI()
            DST:CollectTrainingData()
            DST.trainingFrame.updateFrame.lastUpdate = 0
        end
    end)
end

-- Обновление интерфейса тренировки
function DST:UpdateTrainingUI()
    if not self.isTraining or not self.trainingSession then return end
    
    local currentTime = GetTime()
    local elapsed = currentTime - self.trainingSession.startTime
    local remaining = self.trainingSession.endTime - currentTime
    
    -- Форматирование времени
    local elapsedStr = string.format("%02d:%02d", math.floor(elapsed / 60), math.floor(elapsed % 60))
    local remainingStr = string.format("%02d:%02d", math.floor(remaining / 60), math.floor(remaining % 60))
    
    -- Расчет DPS
    local dps = 0
    if elapsed > 0 then
        dps = self.trainingSession.damageDealt / elapsed
    end
    
    -- Обновление текста
    self.trainingFrame.timer:SetText(string.format("Время: %s / -%s", elapsedStr, remainingStr))
    self.trainingFrame.dps:SetText(string.format("DPS: %.1f", dps))
    self.trainingFrame.spells:SetText(string.format("Заклинаний: %d", self.trainingSession.spellsCast or 0))
end

-- Сбор данных тренировки
function DST:CollectTrainingData()
    if not self.isTraining then return end
    
    -- Сбор данных об уроне (упрощенный метод)
    -- В реальной реализации нужно интегрироваться с Details!
    
    -- Запись состояния для анализа
    local stateData = {
        time = GetTime(),
        health = UnitHealth("player"),
        healthMax = UnitHealthMax("player"),
        power = UnitPower("player"),
        powerMax = UnitPowerMax("player"),
        targetHealth = UnitExists("target") and UnitHealth("target") or 0,
        targetHealthMax = UnitExists("target") and UnitHealthMax("target") or 1
    }
    
    table.insert(self.trainingSession.sessionData, stateData)
    
    -- Ограничение размера данных
    if #self.trainingSession.sessionData > 10000 then
        table.remove(self.trainingSession.sessionData, 1)
    end
end

-- Сбор финальной статистики
function DST:CollectFinalStats()
    if not self.trainingSession then return end
    
    -- Интеграция с Details! для точной статистики
    if Details then
        local currentCombat = Details:GetCurrentCombat()
        if currentCombat then
            local playerData = currentCombat:GetActor(DETAILS_ATTRIBUTE_DAMAGE, UnitName("player"))
            if playerData then
                self.trainingSession.damageDealt = playerData.total
                self.trainingSession.totalDamage = self.trainingSession.totalDamage + playerData.total
                
                -- Сбор статистики по заклинаниям
                for spellID, spellData in pairs(playerData.spells._ActorTable) do
                    if type(spellID) == "number" then
                        local spellName = GetSpellInfo(spellID)
                        if spellName then
                            self.trainingSession.spellUsage[spellName] = {
                                casts = spellData.counter,
                                damage = spellData.total,
                                average = spellData.total / math.max(spellData.counter, 1)
                            }
                            
                            self.trainingSession.spellsCast = (self.trainingSession.spellsCast or 0) + spellData.counter
                        end
                    end
                end
            end
        end
    end
    
    -- Расчет среднего DPS
    local elapsed = GetTime() - self.trainingSession.startTime
    if elapsed > 0 then
        self.trainingSession.averageDPS = self.trainingSession.damageDealt / elapsed
        self.trainingSession.totalTime = self.trainingSession.totalTime + elapsed
        
        -- Обновление лучшего DPS
        if self.trainingSession.averageDPS > self.TrainingStats.bestDPS then
            self.TrainingStats.bestDPS = self.trainingSession.averageDPS
        end
    end
end

-- Анализ результатов тренировки
function DST:AnalyzeTrainingResults()
    if not self.trainingSession then return end
    
    self:Print("=== Анализ результатов тренировки ===")
    
    -- Анализ эффективности заклинаний
    if self.trainingSession.spellUsage and next(self.trainingSession.spellUsage) then
        self:Print("Использование заклинаний:")
        
        local spellsSorted = {}
        for spellName, data in pairs(self.trainingSession.spellUsage) do
            table.insert(spellsSorted, {name = spellName, data = data})
        end
        
        table.sort(spellsSorted, function(a, b)
            return a.data.damage > b.data.damage
        end)
        
        for i = 1, math.min(5, #spellsSorted) do
            local spell = spellsSorted[i]
            self:Print(string.format("  %d. %s: %d урона (%d кастов, средний: %.1f)", 
                i, spell.name, spell.data.damage, spell.data.casts, spell.data.average))
        end
    end
    
    -- Анализ времени боя
    local uptime = 0
    if #self.trainingSession.sessionData > 0 then
        for _, data in ipairs(self.trainingSession.sessionData) do
            if data.targetHealth < data.targetHealthMax then
                uptime = uptime + 0.5  -- +0.5 сек за каждую запись с уроном по цели
            end
        end
    end
    
    local totalTime = #self.trainingSession.sessionData * 0.5
    local uptimePercent = totalTime > 0 and (uptime / totalTime * 100) or 0
    
    self:Print(string.format("Аптайм: %.1f%% (%.1f сек из %.1f сек)", 
        uptimePercent, uptime, totalTime))
    
    -- Рекомендации по улучшению
    self:GenerateRecommendations()
end

-- Генерация рекомендаций
function DST:GenerateRecommendations()
    if not self.trainingSession then return end
    
    local recommendations = {}
    
    -- Проверка использования кулдаунов
    if DBM_Scanner_Spells then
        local cooldowns = DBM_Scanner_Spells.spellCategories and DBM_Scanner_Spells.spellCategories.cooldowns or {}
        
        for _, spell in ipairs(cooldowns) do
            if not self.trainingSession.spellUsage or not self.trainingSession.spellUsage[spell.name] then
                table.insert(recommendations, "Не использовался кулдаун: "..spell.name)
            end
        end
    end
    
    -- Проверка использования DOTов
    if self.trainingSession.spellUsage then
        local dotSpells = {}
        for spellName, _ in pairs(self.trainingSession.spellUsage) do
            if string.find(string.lower(spellName), "огон") or 
               string.find(string.lower(spellName), "яд") or
               string.find(string.lower(spellName), "проклять") then
                dotSpells[spellName] = true
            end
        end
        
        if next(dotSpells) == nil then
            table.insert(recommendations, "Не используются DOTы")
        end
    end
    
    -- Вывод рекомендаций
    if #recommendations > 0 then
        self:Print("Рекомендации для улучшения:")
        for i, rec in ipairs(recommendations) do
            self:Print("  "..i..". "..rec)
        end
    else
        self:Print("Отличная работа! Все основные аспекты покрыты.")
    end
end

-- Сохранение сессии тренировки
function DST:SaveTrainingSession()
    if not self.trainingSession then return end
    
    -- Подготовка данных для сохранения
    local sessionToSave = {
        startTime = self.trainingSession.startTime,
        duration = GetTime() - self.trainingSession.startTime,
        damageDealt = self.trainingSession.damageDealt,
        averageDPS = self.trainingSession.averageDPS,
        spellsCast = self.trainingSession.spellsCast,
        trainingType = self.trainingSession.trainingType,
        playerClass = select(2, UnitClass("player")),
        playerSpec = GetSpecialization()
    }
    
    table.insert(self.TrainingStats.sessions, sessionToSave)
    
    -- Ограничение количества сохраненных сессий
    if #self.TrainingStats.sessions > 100 then
        table.remove(self.TrainingStats.sessions, 1)
    end
    
    -- Сохранение в глобальную переменную
    _G["DBM_Scanner_Training_Stats"] = self.TrainingStats
    
    self:Debug("Сессия тренировки сохранена")
end

-- Загрузка статистики
function DST:LoadStats()
    if _G["DBM_Scanner_Training_Stats"] then
        self.TrainingStats = _G["DBM_Scanner_Training_Stats"]
        self:Debug("Статистика тренировок загружена: "..#self.TrainingStats.sessions.." сессий")
    end
end

-- Получение сводки тренировок
function DST:GetTrainingSummary()
    local summary = {
        totalSessions = #self.TrainingStats.sessions,
        totalDamage = self.TrainingStats.totalDamage,
        totalTime = self.TrainingStats.totalTime,
        bestDPS = self.TrainingStats.bestDPS,
        averageDPS = self.TrainingStats.totalTime > 0 and self.TrainingStats.totalDamage / self.TrainingStats.totalTime or 0
    }
    
    return summary
end

-- Экспорт данных тренировки
function DST:ExportTrainingData()
    local exportData = {
        stats = self.TrainingStats,
        currentSession = self.trainingSession,
        playerInfo = {
            class = select(2, UnitClass("player")),
            spec = GetSpecialization(),
            level = UnitLevel("player")
        },
        exportTime = time()
    }
    
    return exportData
end

-- Автоматическая тренировка при обнаружении манекена
function DST:EnableAutoTraining()
    self.autoTrainingEnabled = true
    
    self.autoTrainingFrame = CreateFrame("Frame")
    self.autoTrainingFrame.lastCheck = 0
    
    self.autoTrainingFrame:SetScript("OnUpdate", function(self, elapsed)
        DST.autoTrainingFrame.lastCheck = DST.autoTrainingFrame.lastCheck + elapsed
        
        if DST.autoTrainingFrame.lastCheck >= 10 then  -- Проверка каждые 10 секунд
            DST.autoTrainingFrame.lastCheck = 0
            
            -- Если не в тренировке и найден манекен
            if not DST.isTraining and DST.autoTrainingEnabled then
                local dummy = DST:FindTrainingDummy()
                if dummy and not UnitAffectingCombat("player") then
                    DST:Print("Обнаружен манекен, начинаю автоматическую тренировку...")
                    DST:StartTraining(15, "auto")  -- 15 минут тренировки
                end
            end
        end
    end)
    
    self:Print("Автоматическая тренировка включена")
end

-- Отладочные функции
function DST:Debug(msg)
    if DBM_Scanner and DBM_Scanner.debug then
        DBM_Scanner:Debug("[Тренировка] "..msg)
    end
end

function DST:Print(msg)
    if DBM_Scanner then
        DBM_Scanner:Print("[Тренировка] "..msg)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFDBM_Scanner Тренировка:|r "..msg)
    end
end

-- Команды для управления тренировкой
SLASH_DBMSCANNERTRAINING1 = "/dbmtrain"

SlashCmdList["DBMSCANNERTRAINING"] = function(msg)
    local cmd = string.lower(msg or "")
    local params = {}
    
    for param in string.gmatch(cmd, "%S+") do
        table.insert(params, param)
    end
    
    if params[1] == "start" then
        local duration = tonumber(params[2]) or 30
        DST:StartTraining(duration)
    elseif params[1] == "stop" then
        DST:StopTraining()
    elseif params[1] == "status" then
        if DST.isTraining then
            DST:Print("Тренировка активна")
            local elapsed = GetTime() - DST.trainingSession.startTime
            DST:Print("Прошло: "..string.format("%.1f", elapsed / 60).." минут")
        else
            DST:Print("Тренировка не активна")
        end
    elseif params[1] == "stats" then
        local summary = DST:GetTrainingSummary()
        DST:Print("=== Статистика тренировок ===")
        DST:Print("Сессий: "..summary.totalSessions)
        DST:Print("Общий урон: "..summary.totalDamage)
        DST:Print("Общее время: "..string.format("%.1f", summary.totalTime / 60).." минут")
        DST:Print("Лучший DPS: "..string.format("%.1f", summary.bestDPS))
        DST:Print("Средний DPS: "..string.format("%.1f", summary.averageDPS))
    elseif params[1] == "auto" then
        DST:EnableAutoTraining()
    elseif params[1] == "help" then
        DST:Print("=== Команды тренировки ===")
        DST:Print("/dbmtrain start [минуты] - Начать тренировку")
        DST:Print("/dbmtrain stop - Остановить тренировку")
        DST:Print("/dbmtrain status - Статус тренировки")
        DST:Print("/dbmtrain stats - Статистика тренировок")
        DST:Print("/dbmtrain auto - Включить авто-тренировку")
    else
        DST:Print("Используйте /dbmtrain help для списка команд")
    end
end

-- Автоматическая инициализация
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(2, function()
            DST:Initialize()
        end)
    end
end)

DST:Print("Модуль тренировки загружен")