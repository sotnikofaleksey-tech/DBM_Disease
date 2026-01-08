-- ==============================================
-- DBM_Scanner_UI - User Interface Module
-- ==============================================
local addonName = "DBM_Scanner_UI"

-- Основная таблица модуля
DBM_Scanner_UI = DBM_Scanner_UI or {}
local DSUI = DBM_Scanner_UI

-- Конфигурация
DSUI.version = "1.0.0"
DSUI.isVisible = true
DSUI.uiScale = 1.0

-- Элементы интерфейса
DSUI.MainFrame = nil
DSUI.StatusFrame = nil
DSUI.SettingsFrame = nil

-- Инициализация интерфейса
function DSUI:Initialize()
    self:Debug("=== Инициализация интерфейса ===")
    
    -- Создание основного интерфейса
    self:CreateMainFrame()
    self:CreateStatusFrame()
    self:CreateSettingsFrame()
    
    -- Загрузка настроек
    self:LoadSettings()
    
    -- Обновление интерфейса
    self:UpdateUI()
    
    self:Debug("Интерфейс инициализирован")
end

-- Создание основного фрейма
function DSUI:CreateMainFrame()
    -- Основной фрейм управления
    self.MainFrame = CreateFrame("Frame", "DBMScannerUIFrame", UIParent)
    self.MainFrame:SetSize(250, 100)
    self.MainFrame:SetPoint("CENTER", 0, 0)
    self.MainFrame:SetMovable(true)
    self.MainFrame:EnableMouse(true)
    self.MainFrame:SetClampedToScreen(true)
    self.MainFrame:SetUserPlaced(true)
    
    -- Фон
    self.MainFrame.bg = self.MainFrame:CreateTexture(nil, "BACKGROUND")
    self.MainFrame.bg:SetAllPoints()
    self.MainFrame.bg:SetColorTexture(0, 0, 0, 0.7)
    
    -- Граница
    self.MainFrame.border = CreateFrame("Frame", nil, self.MainFrame)
    self.MainFrame.border:SetPoint("TOPLEFT", -2, 2)
    self.MainFrame.border:SetPoint("BOTTOMRIGHT", 2, -2)
    self.MainFrame.border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
    })
    self.MainFrame.border:SetBackdropBorderColor(0.5, 0.5, 1, 0.8)
    
    -- Заголовок
    self.MainFrame.title = self.MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.MainFrame.title:SetPoint("TOP", 0, -8)
    self.MainFrame.title:SetText("|cFF00FFFFDBM Scanner|r")
    
    -- Кнопка переключения ротации
    self.MainFrame.toggleBtn = CreateFrame("Button", nil, self.MainFrame, "UIPanelButtonTemplate")
    self.MainFrame.toggleBtn:SetSize(100, 25)
    self.MainFrame.toggleBtn:SetPoint("TOP", 0, -30)
    self.MainFrame.toggleBtn:SetText("Выключено")
    self.MainFrame.toggleBtn:SetScript("OnClick", function()
        if DBM_Scanner then
            DBM_Scanner:ToggleRotation()
            self:UpdateToggleButton()
        end
    end)
    
    -- Кнопка настроек
    self.MainFrame.settingsBtn = CreateFrame("Button", nil, self.MainFrame, "UIPanelButtonTemplate")
    self.MainFrame.settingsBtn:SetSize(80, 20)
    self.MainFrame.settingsBtn:SetPoint("BOTTOMLEFT", 10, 10)
    self.MainFrame.settingsBtn:SetText("Настройки")
    self.MainFrame.settingsBtn:SetScript("OnClick", function()
        self:ToggleSettingsFrame()
    end)
    
    -- Кнопка тренировки
    self.MainFrame.trainBtn = CreateFrame("Button", nil, self.MainFrame, "UIPanelButtonTemplate")
    self.MainFrame.trainBtn:SetSize(80, 20)
    self.MainFrame.trainBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    self.MainFrame.trainBtn:SetText("Тренировка")
    self.MainFrame.trainBtn:SetScript("OnClick", function()
        if DBM_Scanner_Training then
            DBM_Scanner_Training:StartTraining(15)
        end
    end)
    
    -- Перемещение фрейма
    self.MainFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    self.MainFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
            self:SavePosition()
        end
    end)
    
    -- Контекстное меню
    self.MainFrame:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            self:ShowContextMenu()
        end
    end)
    
    -- Скрытие/показ по комбинации клавиш
    self:SetupHotkeys()
end

-- Создание фрейма статуса
function DSUI:CreateStatusFrame()
    self.StatusFrame = CreateFrame("Frame", "DBMScannerStatusFrame", UIParent)
    self.StatusFrame:SetSize(200, 60)
    self.StatusFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
    self.StatusFrame:Hide()
    
    -- Фон
    self.StatusFrame.bg = self.StatusFrame:CreateTexture(nil, "BACKGROUND")
    self.StatusFrame.bg:SetAllPoints()
    self.StatusFrame.bg:SetColorTexture(0, 0, 0, 0.5)
    
    -- Статус ИИ
    self.StatusFrame.aiStatus = self.StatusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.StatusFrame.aiStatus:SetPoint("TOP", 0, -10)
    self.StatusFrame.aiStatus:SetText("ИИ: |cFFFF0000Не обучен|r")
    
    -- Статус ротации
    self.StatusFrame.rotationStatus = self.StatusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.StatusFrame.rotationStatus:SetPoint("TOP", 0, -25)
    self.StatusFrame.rotationStatus:SetText("Ротация: |cFFFF0000Выкл|r")
    
    -- Следующее заклинание
    self.StatusFrame.nextSpell = self.StatusFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    self.StatusFrame.nextSpell:SetPoint("TOP", 0, -40)
    self.StatusFrame.nextSpell:SetText("Следующее: Нет")
    
    -- Авто-обновление
    self.StatusFrame.updater = CreateFrame("Frame")
    self.StatusFrame.updater.lastUpdate = 0
    self.StatusFrame.updater:SetScript("OnUpdate", function(self, elapsed)
        DSUI.StatusFrame.updater.lastUpdate = DSUI.StatusFrame.updater.lastUpdate + elapsed
        if DSUI.StatusFrame.updater.lastUpdate >= 0.5 then
            DSUI:UpdateStatusFrame()
            DSUI.StatusFrame.updater.lastUpdate = 0
        end
    end)
end

-- Создание фрейма настроек
function DSUI:CreateSettingsFrame()
    self.SettingsFrame = CreateFrame("Frame", "DBMScannerSettingsFrame", UIParent)
    self.SettingsFrame:SetSize(300, 400)
    self.SettingsFrame:SetPoint("CENTER", 0, 0)
    self.SettingsFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.SettingsFrame:SetBackdropColor(0, 0, 0, 0.9)
    self.SettingsFrame:Hide()
    self.SettingsFrame:SetFrameStrata("DIALOG")
    
    -- Заголовок
    self.SettingsFrame.title = self.SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.SettingsFrame.title:SetPoint("TOP", 0, -15)
    self.SettingsFrame.title:SetText("|cFF00FFFFНастройки DBM Scanner|r")
    
    -- Закрытие
    self.SettingsFrame.closeBtn = CreateFrame("Button", nil, self.SettingsFrame, "UIPanelCloseButton")
    self.SettingsFrame.closeBtn:SetPoint("TOPRIGHT", -5, -5)
    self.SettingsFrame.closeBtn:SetScript("OnClick", function()
        self.SettingsFrame:Hide()
    end)
    
    -- Прокручиваемая область
    self.SettingsFrame.scrollFrame = CreateFrame("ScrollFrame", "DBMScannerSettingsScrollFrame", self.SettingsFrame, "UIPanelScrollFrameTemplate")
    self.SettingsFrame.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    self.SettingsFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    self.SettingsFrame.scrollChild = CreateFrame("Frame")
    self.SettingsFrame.scrollChild:SetSize(280, 600)
    self.SettingsFrame.scrollFrame:SetScrollChild(self.SettingsFrame.scrollChild)
    
    -- Создание элементов настроек
    self:CreateSettingsElements()
end

-- Создание элементов настроек
function DSUI:CreateSettingsElements()
    local yOffset = -10
    
    -- Общие настройки
    self.SettingsFrame.scrollChild.generalHeader = self.SettingsFrame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.SettingsFrame.scrollChild.generalHeader:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.generalHeader:SetText("|cFFFFFF00Общие настройки|r")
    yOffset = yOffset - 25
    
    -- Включение/выключение аддона
    self.SettingsFrame.scrollChild.enableCheckbox = self:CreateCheckbox("Включить DBM Scanner", 
        self.SettingsFrame.scrollChild, 10, yOffset,
        function(checked)
            if DBM_Scanner then
                DBM_Scanner.enabled = checked
                DSUI:UpdateToggleButton()
            end
        end)
    yOffset = yOffset - 25
    
    -- Режим отладки
    self.SettingsFrame.scrollChild.debugCheckbox = self:CreateCheckbox("Режим отладки", 
        self.SettingsFrame.scrollChild, 10, yOffset,
        function(checked)
            if DBM_Scanner then
                DBM_Scanner.debug = checked
            end
        end)
    yOffset = yOffset - 25
    
    -- Показывать статус
    self.SettingsFrame.scrollChild.showStatusCheckbox = self:CreateCheckbox("Показывать статус", 
        self.SettingsFrame.scrollChild, 10, yOffset,
        function(checked)
            DSUI.isStatusVisible = checked
            if checked then
                DSUI.StatusFrame:Show()
            else
                DSUI.StatusFrame:Hide()
            end
        end, true)
    yOffset = yOffset - 25
    
    -- Настройки ИИ
    self.SettingsFrame.scrollChild.aiHeader = self.SettingsFrame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.SettingsFrame.scrollChild.aiHeader:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.aiHeader:SetText("|cFFFFFF00Настройки ИИ|r")
    yOffset = yOffset - 25
    
    -- Включить обучение ИИ
    self.SettingsFrame.scrollChild.aiLearningCheckbox = self:CreateCheckbox("Включить обучение ИИ", 
        self.SettingsFrame.scrollChild, 10, yOffset,
        function(checked)
            if DBM_Scanner_AI then
                DBM_Scanner_AI.isLearning = checked
            end
        end, true)
    yOffset = yOffset - 25
    
    -- Скорость обучения
    self.SettingsFrame.scrollChild.learningRateSlider = self:CreateSlider("Скорость обучения", 
        self.SettingsFrame.scrollChild, 10, yOffset, 0.01, 0.5, 0.1,
        function(value)
            if DBM_Scanner_AI then
                DBM_Scanner_AI.learningRate = value
            end
        end)
    yOffset = yOffset - 45
    
    -- Уровень исследования
    self.SettingsFrame.scrollChild.explorationSlider = self:CreateSlider("Уровень исследования", 
        self.SettingsFrame.scrollChild, 10, yOffset, 0.0, 1.0, 0.3,
        function(value)
            if DBM_Scanner_AI then
                DBM_Scanner_AI.explorationRate = value
            end
        end)
    yOffset = yOffset - 45
    
    -- Настройки ротации
    self.SettingsFrame.scrollChild.rotationHeader = self.SettingsFrame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.SettingsFrame.scrollChild.rotationHeader:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.rotationHeader:SetText("|cFFFFFF00Настройки ротации|r")
    yOffset = yOffset - 25
    
    -- Задержка между кастами (мс)
    self.SettingsFrame.scrollChild.castDelaySlider = self:CreateSlider("Задержка каста (мс)", 
        self.SettingsFrame.scrollChild, 10, yOffset, 0, 500, 50,
        function(value)
            if DBM_Scanner then
                DBM_Scanner.castDelay = value / 1000
            end
        end)
    yOffset = yOffset - 45
    
    -- Минимальный HP для отмены каста
    self.SettingsFrame.scrollChild.minHealthSlider = self:CreateSlider("Мин. HP для каста (%)", 
        self.SettingsFrame.scrollChild, 10, yOffset, 0, 100, 20,
        function(value)
            if DBM_Scanner then
                DBM_Scanner.minHealthPercent = value
            end
        end)
    yOffset = yOffset - 45
    
    -- Настройки интерфейса
    self.SettingsFrame.scrollChild.uiHeader = self.SettingsFrame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.SettingsFrame.scrollChild.uiHeader:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.uiHeader:SetText("|cFFFFFF00Настройки интерфейса|r")
    yOffset = yOffset - 25
    
    -- Масштаб интерфейса
    self.SettingsFrame.scrollChild.uiScaleSlider = self:CreateSlider("Масштаб интерфейса", 
        self.SettingsFrame.scrollChild, 10, yOffset, 0.5, 2.0, 1.0,
        function(value)
            DSUI.uiScale = value
            DSUI.MainFrame:SetScale(value)
            DSUI.StatusFrame:SetScale(value)
        end)
    yOffset = yOffset - 45
    
    -- Прозрачность
    self.SettingsFrame.scrollChild.uiAlphaSlider = self:CreateSlider("Прозрачность", 
        self.SettingsFrame.scrollChild, 10, yOffset, 0.1, 1.0, 1.0,
        function(value)
            DSUI.MainFrame:SetAlpha(value)
            DSUI.StatusFrame:SetAlpha(value * 0.8)
        end)
    yOffset = yOffset - 45
    
    -- Кнопки действий
    self.SettingsFrame.scrollChild.actionsHeader = self.SettingsFrame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.SettingsFrame.scrollChild.actionsHeader:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.actionsHeader:SetText("|cFFFFFF00Действия|r")
    yOffset = yOffset - 25
    
    -- Кнопка сканирования заклинаний
    self.SettingsFrame.scrollChild.scanBtn = CreateFrame("Button", nil, self.SettingsFrame.scrollChild, "UIPanelButtonTemplate")
    self.SettingsFrame.scrollChild.scanBtn:SetSize(120, 25)
    self.SettingsFrame.scrollChild.scanBtn:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.scanBtn:SetText("Сканировать заклинания")
    self.SettingsFrame.scrollChild.scanBtn:SetScript("OnClick", function()
        if DBM_Scanner_Spells then
            DBM_Scanner_Spells:ScanAllSpells()
        end
    end)
    
    -- Кнопка очистки данных ИИ
    self.SettingsFrame.scrollChild.clearBtn = CreateFrame("Button", nil, self.SettingsFrame.scrollChild, "UIPanelButtonTemplate")
    self.SettingsFrame.scrollChild.clearBtn:SetSize(120, 25)
    self.SettingsFrame.scrollChild.clearBtn:SetPoint("TOPLEFT", 140, yOffset)
    self.SettingsFrame.scrollChild.clearBtn:SetText("Очистить данные ИИ")
    self.SettingsFrame.scrollChild.clearBtn:SetScript("OnClick", function()
        DSUI:ConfirmClearAIData()
    end)
    
    yOffset = yOffset - 35
    
    -- Кнопка экспорта данных
    self.SettingsFrame.scrollChild.exportBtn = CreateFrame("Button", nil, self.SettingsFrame.scrollChild, "UIPanelButtonTemplate")
    self.SettingsFrame.scrollChild.exportBtn:SetSize(120, 25)
    self.SettingsFrame.scrollChild.exportBtn:SetPoint("TOPLEFT", 10, yOffset)
    self.SettingsFrame.scrollChild.exportBtn:SetText("Экспорт данных")
    self.SettingsFrame.scrollChild.exportBtn:SetScript("OnClick", function()
        DSUI:ExportAllData()
    end)
    
    -- Кнопка импорта данных
    self.SettingsFrame.scrollChild.importBtn = CreateFrame("Button", nil, self.SettingsFrame.scrollChild, "UIPanelButtonTemplate")
    self.SettingsFrame.scrollChild.importBtn:SetSize(120, 25)
    self.SettingsFrame.scrollChild.importBtn:SetPoint("TOPLEFT", 140, yOffset)
    self.SettingsFrame.scrollChild.importBtn:SetText("Импорт данных")
    self.SettingsFrame.scrollChild.importBtn:SetScript("OnClick", function()
        DSUI:ShowImportDialog()
    end)
end

-- Создание чекбокса
function DSUI:CreateCheckbox(text, parent, x, y, callback, defaultState)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox:SetSize(24, 24)
    
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(text)
    
    checkbox:SetScript("OnClick", function(self)
        if callback then
            callback(self:GetChecked())
        end
    end)
    
    if defaultState then
        checkbox:SetChecked(defaultState)
        if callback then
            callback(defaultState)
        end
    end
    
    return checkbox
end

-- Создание слайдера
function DSUI:CreateSlider(text, parent, x, y, min, max, defaultValue, callback)
    local slider = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", x, y)
    slider:SetSize(180, 20)
    slider:SetMinMaxValues(min, max)
    slider:SetValue(defaultValue)
    slider:SetValueStep((max - min) / 100)
    
    slider.text = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.text:SetPoint("BOTTOM", slider, "TOP", 0, 3)
    slider.text:SetText(text .. ": " .. defaultValue)
    
    slider.lowText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.lowText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -5)
    slider.lowText:SetText(min)
    
    slider.highText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.highText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -5)
    slider.highText:SetText(max)
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100) / 100
        self.text:SetText(text .. ": " .. value)
        if callback then
            callback(value)
        end
    end)
    
    return slider
end

-- Обновление интерфейса
function DSUI:UpdateUI()
    self:UpdateToggleButton()
    self:UpdateStatusFrame()
    
    -- Обновление настроек
    if self.SettingsFrame and self.SettingsFrame:IsShown() then
        self:UpdateSettingsValues()
    end
end

-- Обновление кнопки переключения
function DSUI:UpdateToggleButton()
    if not self.MainFrame or not self.MainFrame.toggleBtn then return end
    
    if DBM_Scanner and DBM_Scanner.enabled then
        self.MainFrame.toggleBtn:SetText("|cFF00FF00ВКЛЮЧЕНО|r")
        self.MainFrame.toggleBtn:GetNormalTexture():SetVertexColor(0, 1, 0, 0.5)
    else
        self.MainFrame.toggleBtn:SetText("|cFFFF0000ВЫКЛЮЧЕНО|r")
        self.MainFrame.toggleBtn:GetNormalTexture():SetVertexColor(1, 0, 0, 0.5)
    end
end

-- Обновление фрейма статуса
function DSUI:UpdateStatusFrame()
    if not self.StatusFrame or not self.isStatusVisible then return end
    
    -- Статус ИИ
    local aiStatus = "|cFFFF0000Не обучен|r"
    local aiColor = "FF0000"
    
    if DBM_Scanner_AI then
        if DBM_Scanner_AI:IsTrained() then
            aiStatus = "|cFF00FF00Обучен|r"
            aiColor = "00FF00"
        elseif DBM_Scanner_AI.isLearning then
            aiStatus = "|cFFFFFF00Обучается|r"
            aiColor = "FFFF00"
        end
    end
    
    self.StatusFrame.aiStatus:SetText("ИИ: "..aiStatus)
    
    -- Статус ротации
    local rotationStatus = "|cFFFF0000Выкл|r"
    if DBM_Scanner and DBM_Scanner.enabled then
        rotationStatus = "|cFF00FF00Вкл|r"
    end
    
    self.StatusFrame.rotationStatus:SetText("Ротация: "..rotationStatus)
    
    -- Следующее заклинание (если в бою)
    local nextSpellText = "Следующее: Нет"
    if DBM_Scanner and DBM_Scanner.enabled and UnitAffectingCombat("player") then
        if DBM_Scanner.lastSpell then
            local spellName = DBM_Scanner.lastSpell.name or DBM_Scanner.lastSpell
            nextSpellText = "Следующее: |cFFFFFF00"..spellName.."|r"
        end
    end
    
    self.StatusFrame.nextSpell:SetText(nextSpellText)
end

-- Обновление значений в настройках
function DSUI:UpdateSettingsValues()
    if not self.SettingsFrame then return end
    
    -- Устанавливаем значения чекбоксов
    if self.SettingsFrame.scrollChild.enableCheckbox then
        self.SettingsFrame.scrollChild.enableCheckbox:SetChecked(DBM_Scanner and DBM_Scanner.enabled or false)
    end
    
    if self.SettingsFrame.scrollChild.debugCheckbox then
        self.SettingsFrame.scrollChild.debugCheckbox:SetChecked(DBM_Scanner and DBM_Scanner.debug or false)
    end
    
    if self.SettingsFrame.scrollChild.aiLearningCheckbox and DBM_Scanner_AI then
        self.SettingsFrame.scrollChild.aiLearningCheckbox:SetChecked(DBM_Scanner_AI.isLearning)
    end
    
    -- Устанавливаем значения слайдеров
    if self.SettingsFrame.scrollChild.learningRateSlider and DBM_Scanner_AI then
        self.SettingsFrame.scrollChild.learningRateSlider:SetValue(DBM_Scanner_AI.learningRate)
    end
    
    if self.SettingsFrame.scrollChild.explorationSlider and DBM_Scanner_AI then
        self.SettingsFrame.scrollChild.explorationSlider:SetValue(DBM_Scanner_AI.explorationRate)
    end
end

-- Переключение фрейма настроек
function DSUI:ToggleSettingsFrame()
    if self.SettingsFrame:IsShown() then
        self.SettingsFrame:Hide()
    else
        self.SettingsFrame:Show()
        self:UpdateSettingsValues()
    end
end

-- Сохранение позиции
function DSUI:SavePosition()
    if not self.MainFrame then return end
    
    local point, _, relativePoint, x, y = self.MainFrame:GetPoint()
    
    _G["DBM_Scanner_UI_Position"] = {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
        scale = self.uiScale
    }
end

-- Загрузка настроек
function DSUI:LoadSettings()
    -- Позиция
    if _G["DBM_Scanner_UI_Position"] then
        local pos = _G["DBM_Scanner_UI_Position"]
        if self.MainFrame then
            self.MainFrame:ClearAllPoints()
            self.MainFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
            self.uiScale = pos.scale or 1.0
            self.MainFrame:SetScale(self.uiScale)
        end
    end
    
    -- Видимость статуса
    self.isStatusVisible = _G["DBM_Scanner_UI_ShowStatus"] or true
    if self.StatusFrame then
        if self.isStatusVisible then
            self.StatusFrame:Show()
        else
            self.StatusFrame:Hide()
        end
    end
end

-- Настройка горячих клавиш
function DSUI:SetupHotkeys()
    -- Регистрируем сочетание клавиш для показа/скрытия
    local keyBindFrame = CreateFrame("Frame")
    keyBindFrame:RegisterEvent("UPDATE_BINDINGS")
    
    keyBindFrame:SetScript("OnEvent", function()
        -- Можно добавить кастомные бинды клавиш
    end)
    
    -- Alt+Shift+D для быстрого переключения
    SetOverrideBindingClick(keyBindFrame, false, "ALT-SHIFT-D", self.MainFrame.toggleBtn:GetName())
end

-- Показать контекстное меню
function DSUI:ShowContextMenu()
    local menu = {
        {
            text = "DBM Scanner " .. self.version,
            isTitle = true,
            notCheckable = true
        },
        {
            text = "Скрыть интерфейс",
            func = function() 
                self.MainFrame:Hide()
                self.StatusFrame:Hide()
            end,
            notCheckable = true
        },
        {
            text = "Показать все",
            func = function() 
                self.MainFrame:Show()
                if self.isStatusVisible then
                    self.StatusFrame:Show()
                end
            end,
            notCheckable = true
        },
        {
            text = "Сбросить позицию",
            func = function() 
                self.MainFrame:ClearAllPoints()
                self.MainFrame:SetPoint("CENTER", 0, 0)
                self:SavePosition()
            end,
            notCheckable = true
        },
        {
            text = "Экспорт всех данных",
            func = function() 
                self:ExportAllData()
            end,
            notCheckable = true
        },
        {
            text = "Справка",
            func = function() 
                self:ShowHelp()
            end,
            notCheckable = true
        }
    }
    
    EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU")
end

-- Экспорт всех данных
function DSUI:ExportAllData()
    local exportData = {
        version = self.version,
        exportTime = time(),
        
        -- Данные ИИ
        aiData = DBM_Scanner_AI and DBM_Scanner_AI.KnowledgeBase or nil,
        
        -- Данные заклинаний
        spellData = DBM_Scanner_Spells and DBM_Scanner_Spells:ExportSpellData() or nil,
        
        -- Данные тренировок
        trainingData = DBM_Scanner_Training and DBM_Scanner_Training:ExportTrainingData() or nil,
        
        -- Настройки
        settings = {
            uiPosition = _G["DBM_Scanner_UI_Position"],
            uiShowStatus = _G["DBM_Scanner_UI_ShowStatus"]
        }
    }
    
    -- Преобразование в строку (в реальном использовании нужно сериализовать)
    local exportString = "DBM_Scanner_Export_" .. time() .. " = {\n"
    exportString = exportString .. "  -- Экспорт данных DBM Scanner\n"
    exportString = exportString .. "  -- Время экспорта: " .. date("%Y-%m-%d %H:%M:%S") .. "\n"
    exportString = exportString .. "  version = '" .. exportData.version .. "',\n"
    exportString = exportString .. "}\n"
    
    -- В реальной реализации здесь была бы полная сериализация
    -- Для примера просто показываем сообщение
    self:Print("Экспорт данных выполнен (упрощенно)")
    self:Print("Данные сохранены в глобальных переменных:")
    self:Print("  DBM_Scanner_AI_SaveData")
    self:Print("  DBM_Scanner_Training_Stats")
    self:Print("  DBM_Scanner_UI_Position")
end

-- Подтверждение очистки данных ИИ
function DSUI:ConfirmClearAIData()
    StaticPopupDialogs["DBM_SCANNER_CLEAR_AI_CONFIRM"] = {
        text = "Вы уверены, что хотите очистить все данные ИИ? Это действие нельзя отменить.",
        button1 = "Да, очистить",
        button2 = "Отмена",
        OnAccept = function()
            if DBM_Scanner_AI then
                DBM_Scanner_AI.KnowledgeBase = {classes = {}}
                DBM_Scanner_AI:InitializeForClass()
                DSUI:Print("Данные ИИ очищены")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    StaticPopup_Show("DBM_SCANNER_CLEAR_AI_CONFIRM")
end

-- Показать диалог импорта
function DSUI:ShowImportDialog()
    self:Print("Импорт данных пока не реализован")
    self:Print("В будущих версиях будет доступен импорт из файла")
end

-- Показать справку
function DSUI:ShowHelp()
    local helpFrame = CreateFrame("Frame", "DBMScannerHelpFrame", UIParent)
    helpFrame:SetSize(400, 300)
    helpFrame:SetPoint("CENTER", 0, 0)
    helpFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    helpFrame:SetBackdropColor(0, 0, 0, 0.9)
    helpFrame:SetFrameStrata("DIALOG")
    
    -- Заголовок
    helpFrame.title = helpFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    helpFrame.title:SetPoint("TOP", 0, -15)
    helpFrame.title:SetText("|cFF00FFFFСправка DBM Scanner|r")
    
    -- Закрытие
    helpFrame.closeBtn = CreateFrame("Button", nil, helpFrame, "UIPanelCloseButton")
    helpFrame.closeBtn:SetPoint("TOPRIGHT", -5, -5)
    helpFrame.closeBtn:SetScript("OnClick", function()
        helpFrame:Hide()
    end)
    
    -- Текст справки
    helpFrame.scrollFrame = CreateFrame("ScrollFrame", "DBMScannerHelpScrollFrame", helpFrame, "UIPanelScrollFrameTemplate")
    helpFrame.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    helpFrame.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)
    
    helpFrame.scrollChild = CreateFrame("Frame")
    helpFrame.scrollChild:SetSize(380, 500)
    helpFrame.scrollFrame:SetScrollChild(helpFrame.scrollChild)
    
    local helpText = helpFrame.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    helpText:SetPoint("TOPLEFT", 10, -10)
    helpText:SetJustifyH("LEFT")
    helpText:SetJustifyV("TOP")
    helpText:SetWidth(360)
    
    local text = [[
|cFFFFFF00DBM Scanner v]]..self.version..[[|r

|cFF00FFFFОсновные функции:|r
• Автоматическая ротация с ИИ обучением
• Авто-сканирование заклинаний и талантов
• Режим тренировки на манекене
• Адаптация под кастомные сервера

|cFF00FFFFБыстрый старт:|r
1. Зайдите на персонажа
2. Введите |cFFFFFF00/dbms on|r
3. Найдите тренировочный манекен
4. Введите |cFFFFFF00/dbmtrain start 30|r

|cFF00FFFFОсновные команды:|r
• |cFFFFFF00/dbms|r - Управление аддоном
• |cFFFFFF00/dbmtrain|r - Управление тренировкой
• |cFFFFFF00/dbmspells|r - Управление заклинаниями

|cFF00FFFFОбучение ИИ:|r
ИИ учится на ваших действиях в бою. Для ускорения обучения:
1. Используйте режим тренировки
2. Позвольте ИИ исследовать разные варианты
3. Чем больше данных - тем умнее ИИ

|cFF00FFFFИнтеграция:|r
• Details! - сбор статистики урона
• DBM/BigWigs - информация о боях
• Ваши существующие аддоны ротации

|cFFFF0000Важно:|r
Аддон работает в рамках разрешенного API WoW.
Не нарушайте правила сервера.
    ]]
    
    helpText:SetText(text)
    
    helpFrame:Show()
end

-- Отладочные функции
function DSUI:Debug(msg)
    if DBM_Scanner and DBM_Scanner.debug then
        DBM_Scanner:Debug("[Интерфейс] "..msg)
    end
end

function DSUI:Print(msg)
    if DBM_Scanner then
        DBM_Scanner:Print("[Интерфейс] "..msg)
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFFDBM_Scanner Интерфейс:|r "..msg)
    end
end

-- Автоматическая инициализация
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        C_Timer.After(3, function()
            DSUI:Initialize()
        end)
    end
end)

DSUI:Print("Модуль интерфейса загружен")