-- DBM_Disease DemonHunter Module
-- FULL ORIGINAL CODE FOR DEMON HUNTER - NO CHANGES

-- Module registration
DBM_Disease_Modules = DBM_Disease_Modules or {}
DBM_Disease_Modules.DemonHunter = {
    name = "DemonHunter",
    class = "DEMONHUNTER",
    
    Initialize = function()
        -- Debug output
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("=== Loading DemonHunter Rotation Module ===")
        else
            DEFAULT_CHAT_FRAME:AddMessage("DBM_Disease: Loading DemonHunter module...")
        end
        
        -- Original code starts here - EXACT COPY
        -- Проверка: работает только для класса DEMONHUNTER (охотник на демонов)
        if select(2,UnitClass('player'))~='DEMONHUNTER'then return end;

        -- Локальная копия функции select для оптимизации
        local select=select;

        -- Таблица символов для генерации случайных имен (обфускация)
        local b={
        [1]="q",[2]="w",[3]="e",[4]="rR",[5]="tT",[6]="yR",[7]="u",[8]="iI",[9]="o",[10]="p",
        [11]="a",[12]="s",[13]="d",[14]="f",[15]="g",[16]="h",[17]="j",[18]="k",[19]="l",
        [20]="z",[21]="x",[22]="c",[23]="v",[24]="b",[25]="n",[26]="m",[27]="Q",[28]="W",
        [29]="E",[30]="R",[31]="T",[32]="Y",[33]="A",[34]="S",[35]="D",[36]="F",[37]="G",
        [38]="H",[39]="J",[40]="K"
        }

        -- Инициализация пустой таблицы
        local c={}

        -- Функция генерации случайной строки (обфускация имен переменных)
        local function d(e)
            local e=e or 8  -- По умолчанию длина 8 символов
            for f=1,e do 
                table.insert(c,b[math.random(1,#b)])  -- Добавляем случайный символ
            end
            a=table.concat(c)  -- Объединяем символы в строку
            return a 
        end

        -- Генерация случайного имени для глобальной таблицы (9 символов)
        local g=d(9)
        -- Создание глобальной таблицы со случайным именем
        _G[g]={}

        -- Создание случайных имен для элементов интерфейса (обфускация)
        b.GameMenuFrameTextTimeLeft=d(12)
        b.GameMenuFrameTextTimeLeft=CreateFrame("Frame")
        _G[g].time_text=d(11)
        local y=_G[g].time_text;
        -- Создание текстовой строки в меню игры
        local z=GameMenuFrame:CreateFontString(y)
        z:SetPoint("BOTTOM",0,-16)  -- Позиция
        z:SetParent(GameMenuFrame)  -- Родительский фрейм
        z:SetJustifyH("LEFT")  -- Выравнивание по левому краю
        z:SetFont("Fonts\\ARIALN.ttf",14,"OUTLINE, MONOCHROME")  -- Шрифт
        z:SetSize(200,20)  -- Размер

        -- Функция преобразования HEX цвета в RGB
        _G[g].hex2rgb=function(A)
            A=A:gsub("#","")  -- Удаление символа #
            return tonumber("0x"..A:sub(1,2))/255,tonumber("0x"..A:sub(3,4))/255,tonumber("0x"..A:sub(5,6))/255 
        end;

        -- Функция возврата цветового кода для имени по классу
        _G[g].UnitName_Color=function(B)
            local C,D=UnitClass(B)  -- Получение класса юнита
            local E=""  -- Цветовой код
            -- Выбор цвета в зависимости от класса
            if D=="WARRIOR" then E="|cffC79C6E"
            elseif D=="PALADIN" then E="|cffF58CBA"
            elseif D=="HUNTER" then E="|cffABD473"
            elseif D=="ROGUE" then E="|cffFFF569"
            elseif D=="PRIEST" then E="|cffFFFFFF"
            elseif D=="DEATHKNIGHT" then E="|cffC41F3B"
            elseif D=="SHAMAN" then E="|cff0070DE"
            elseif D=="MAGE" then E="|cff69CCF0"
            elseif D=="WARLOCK" then E="|cff9482C9"
            elseif D=="MONK" then E="|cff00FF96"
            elseif D=="DRUID" then E="|cffFF7D0A"
            elseif D=="DEMONHUNTER" then E="|cffA330C9"
            end
            return E 
        end;

        -- Функция обновления фрейма уведомлений (постепенное исчезновение)
        _G[g].PQ_NotifyFrame_OnUpdate=function()
            if _G[g].PQ_NotifyFrameTime<GetTime()-1.5 then 
                local F=_G[g].PQ_NotifyFrame:GetAlpha()  -- Текущая прозрачность
                if F~=0 then 
                    _G[g].PQ_NotifyFrame:SetAlpha(F-.02)  -- Уменьшение прозрачность
                end
                if aplpa==0 then  -- Опечатка: должно быть alpha, а не aplha
                    _G[g].PQ_NotifyFrame:Hide()  -- Скрытие фрейма
                end 
            end 
        end;

        -- Функция показа уведомления
        _G[g].Alert=function(G)
            _G[g].PQ_NotifyFrame.text:SetText(G)  -- Установка текста
            _G[g].PQ_NotifyFrame:SetAlpha(1)  -- Полная непрозрачность
            _G[g].PQ_NotifyFrame:Show()  -- Показать фрейм
            _G[g].PQ_NotifyFrameTime=GetTime()  -- Запись времени показа
        end;

        -- Создание фрейма уведомлений
        _G[g].PQ_NotifyFrame=CreateFrame('Frame')
        _G[g].PQ_NotifyFrame:ClearAllPoints()
        _G[g].PQ_NotifyFrame:SetHeight(1200)
        _G[g].PQ_NotifyFrame:SetWidth(300)
        _G[g].PQ_NotifyFrame:SetScript('OnUpdate',_G[g].PQ_NotifyFrame_OnUpdate)  -- Привязка функции обновления
        _G[g].PQ_NotifyFrame:Hide()
        _G[g].PQ_NotifyFrame.text=_G[g].PQ_NotifyFrame:CreateFontString(nil,'BACKGROUND','PVPInfoTextFont')
        _G[g].PQ_NotifyFrame.text:SetAllPoints()
        _G[g].PQ_NotifyFrame:SetPoint('CENTER',0,200)  -- Позиция по центру экрана
        _G[g].PQ_NotifyFrameTime=0;  -- Инициализация времени

        -- Функция создания фрейма режима ротации (включение/выключение бота)
        _G[g].RotMode=function()
            RegisterCVar("VadimRogueRM",2)  -- Регистрация переменной с значением по умолчанию (2 = выключено)
            _G[g].RotMode=CreateFrame("Frame","Kerjn228")  -- Создание фрейма
            _G[g].RotMode:SetPoint("CENTER",0,-300)  -- Позиция
            _G[g].RotMode:SetSize(60,20)  -- Размер
            _G[g].RotMode:SetParent(UIParent)  -- Родительский фрейм
            _G[g].RotMode.art_f=_G[g].RotMode:CreateTexture()  -- Текстура фона
            _G[g].RotMode.art_f:SetAllPoints()
            _G[g].RotMode.art_f:SetColorTexture(0,0,0,1)  -- Черный цвет
            _G[g].RotMode.art_f:SetAlpha(1)
            _G[g].RotMode.ftr=_G[g].RotMode:CreateFontString(nil,"OVERLAY","QuestFont")  -- Текстовое поле
            _G[g].RotMode.ftr:SetPoint("CENTER",0,0)
            -- Фрейм для обновления текста в реальном времени
            _G[g].RotMode.fm=CreateFrame("Frame")
            _G[g].RotMode.fm:SetScript("OnUpdate",function()
                -- Отображение состояния: включено (зеленый) или выключено (красный)
                if GetCVar("VadimRogueRM")=="1" then 
                    _G[g].RotMode.ftr:SetText("|cff00FF00Вкл|r")
                end
                if GetCVar("VadimRogueRM")=="2" then 
                    _G[g].RotMode.ftr:SetText("|cffFF0000Выкл|r")
                end 
            end)
            -- Включение перемещения фрейма мышью
            _G[g].RotMode:EnableMouse(true)
            _G[g].RotMode:SetMovable(true)
            _G[g].RotMode:SetUserPlaced(true)
            _G[g].RotMode:SetScript("OnMouseDown",function(self)
                self:StartMoving()  -- Начать перемещение
            end)
            _G[g].RotMode:SetScript("OnMouseUp",function(self)
                self:StopMovingOrSizing()  -- Остановить перемещение
            end)
            _G[g].RotMode:SetScript("OnDragStop",function(self)
                StopMovingOrSizing()  -- Остановить перемещение (дублирующая функция)
            end)
        end;

        -- Вызов функции создания фрейма режима ротации
        _G[g].RotMode()

        -- Функция проверки времени восстановления заклинания
        _G[g].CDSpell=function(H)
            if select(2,GetSpellCooldown(H))+select(1,GetSpellCooldown(H))-GetTime()>0 then 
                return select(2,GetSpellCooldown(H))+select(1,GetSpellCooldown(H))-GetTime()
            else 
                return 0 
            end 
        end;

        -- Определение глобальных переменных для часто используемых сущностей
        local c="target"  -- Цель
        local I="player"  -- Игрок
        local z="focus"   -- Фокус
        local y=GetSpellInfo;  -- Функция получения информации о заклинании
        local J=UnitBuff;  -- Функция проверки баффов
        local K=d(1)  -- Генерация случайного имени для переменной
        _G[g].table_spell={}  -- Инициализация таблицы заклинаний
        local C,L=UnitClass(I)  -- Получение класса игрока
        local M=CastSpellByName;  -- Функция применения заклинания по имени
        local N=_G[g].CDSpell;  -- Ссылка на функцию проверки КД

        -- Функция получения иконки заклинания
        function Icon(O)
            local C,C,P=GetSpellInfo(O)  -- Получение информации о заклинании
            str="|T"..P..":24:24|t"  -- Формирование строки с иконкой
            return str 
        end;

        -- Регистрация переменных для отладки и функционала
        RegisterCVar("GMMODE","0")  -- Режим отладки (0 - выключен)
        RegisterCVar("VadimUnlocker2022","0")  -- Имя текущего заклинания
        RegisterCVar("VadimUnlocker2022icon","0")  -- Иконка текущего заклинания
        RegisterCVar("VadimUnlocker2022id","0")  -- ID текущего заклинания

        -- Создание таблицы всех известных игроку заклинаний
        local P={}
        for f=1,3000000 do  -- Перебор возможных ID заклинаний
            if GetSpellInfo(f) and IsSpellKnown(f) then  -- Если заклинание существует и известно
                P[#P+1]={name=GetSpellInfo(f),icon=select(3,GetSpellInfo(f)),id=select(7,GetSpellInfo(f))}  -- Сохранение данных
            end 
        end;

        -- Функция поиска заклинания по иконке и сохранения в переменные
        function _Get(Q)
            -- Преобразуем числовую текстуру в строковый путь
            local texturePath
            if type(Q) == "number" then
                texturePath = "Interface\\Icons\\" .. Q
            else
                texturePath = Q
            end
            
            for R,S in pairs(P) do 
                local spellTexture = S.icon
                if type(spellTexture) == "number" then
                    spellTexture = "Interface\\Icons\\" .. spellTexture
                end
                
                if spellTexture == texturePath then  -- Если иконка совпадает
                    SetCVar("VadimUnlocker2022",S.name)  -- Сохраняем имя
                    SetCVar("VadimUnlocker2022icon",S.icon)  -- Сохраняем иконку
                    SetCVar("VadimUnlocker2022id",S.id)  -- Сохраняем ID
                    return true
                end 
            end
            return false
        end;

        -- Основная функция автоматической ротации
        local function T()
            local U=GetSpecialization()  -- Текущая специализация
            local V=UnitAffectingCombat(I)  -- Проверка в бою ли игрок
            
            -- Если режим ротации выключен - выходим
            if GetCVar("VadimRogueRM")=="2" then 
                return 
            end;
            
            -- Если игрок произносит заклинание - выходим
            if UnitCastingInfo(I) or UnitChannelInfo(I) then 
                return 
            end;
            
            -- Если цель не существует или мертва - выходим
            if not UnitExists(c) or UnitIsDead(c) then 
                return 
            end;
            
            -- Если нельзя атаковать цель - выходим
            if not UnitCanAttack(I,c) then 
                return 
            end;
            
            -- Если игрок на транспорте - выходим
            if IsMounted() then 
                return 
            end;
            
            -- Для специализации "Истребление" (1) и "Месть" (2) - используем Hekili
            if (U==1 or U==2) and L=="DEMONHUNTER" then 
                -- ПЕРВЫЙ ПРИОРИТЕТ: артефакт
                if GetCVar("VadimRogueRM")=="1" then
                    local artifactID = 201467  -- Ярость Иллидари
                    if N(artifactID) == 0 then
                        local artifactName = GetSpellInfo(artifactID)
                        if artifactName then
                            CastSpellByName(artifactName)
                            return
                        end
                    end
                end
                
                -- Простой поиск активного заклинания в Hekili
                local foundSpell = false
                local spellName = ""
                local spellID = 0
                
                -- Проверяем все фреймы Hekili_D1_B1-B5
                for j=1,5 do
                    local frameName = "Hekili_D1_B"..j
                    local frame = _G[frameName]
                    if frame and frame.Texture then
                        local texture = frame.Texture:GetTexture()
                        -- Пропускаем дефолтные текстуры
                        if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                            local found = _Get(texture)
                            if found then
                                spellName = GetCVar("VadimUnlocker2022")
                                spellID = tonumber(GetCVar("VadimUnlocker2022id"))
                                
                                -- Игнорируем автоматическую атаку
                                if spellID ~= 6603 and spellName ~= "Автоматическая атака" and spellName ~= "" then
                                    foundSpell = true
                                    break
                                end
                            end
                        end
                    end
                end
                
                if foundSpell and GetCVar("VadimRogueRM")=="1" then
                    -- Проверяем КД
                    if N(spellID) == 0 then
                        -- Специальные заклинания, требующие курсора
                        local cursorSpells = {
                            [191427] = true, -- Метаморфоза
                            [162243] = true, -- Демонический прыжок
                            [195072] = true, -- Прыжок
                            [218256] = true, -- Рывок
                            [189110] = true, -- Разрушительный прыжок/Инфернальный удар
                            [204596] = true, -- Печать пламени
                            [202137] = true, -- Печать молчания
                            [189112] = true, -- Круг страданий
                        }
                        
                        -- Задержка между кастами для предотвращения спама
                        local currentTime = GetTime()
                        _G[g].lastCastTime = _G[g].lastCastTime or 0
                        _G[g].lastCastSpell = _G[g].lastCastSpell or ""
                        
                        -- Если это то же заклинание, что и предыдущее, ждем 0.3 секунды
                        if _G[g].lastCastSpell == spellName and (currentTime - _G[g].lastCastTime) < 0.5 then
                            return
                        end
                        
                        -- Список заклинаний, для которых НЕ нужно проверять радиус
                        local noRangeCheckSpells = {
                            [162794] = true, -- Удар хаоса (ближний бой)
                            [227518] = true, -- Аннигиляция (ближний бой)
                            [201427] = true, -- Аннигиляция (альтернативный ID)
                            [191427] = true, -- Метаморфоза
                            [162243] = true, -- Демонический прыжок
                            [195072] = true, -- Прыжок
                            [218256] = true, -- Рывок
                            [189110] = true, -- Разрушительный прыжок/Инфернальный удар
                            [204596] = true, -- Печать пламени
                            [202137] = true, -- Печать молчания
                            [189112] = true, -- Круг страданий
                            [201467] = true, -- Ярость Иллидари
                        }
                        
                        -- Проверяем, нужно ли проверять радиус для этого заклинания
                        local shouldCheckRange = not noRangeCheckSpells[spellID]
                        
                        -- Если не нужно проверять радиус или заклинание в радиусе - кастуем
                        local canCast = false
                        
                        if not shouldCheckRange then
                            canCast = true  -- Не проверяем радиус
                        else
                            -- Проверяем радиус
                            local spellInfo = GetSpellInfo(spellID)
                            if spellInfo then
                                local inRange = IsSpellInRange(spellInfo, c)
                                if inRange == 1 or inRange == nil then
                                    canCast = true
                                end
                            end
                        end
                        
                        if canCast then
                            if cursorSpells[spellID] then
                                -- Кастуем на курсор
                                RunMacroText("/cast [@cursor] " .. spellName)
                            else
                                -- Обычный каст
                                CastSpellByName(spellName)
                            end
                            
                            -- Запоминаем время и название последнего заклинания
                            _G[g].lastCastTime = currentTime
                            _G[g].lastCastSpell = spellName
                            return
                        end
                    end
                end
                
                -- ВТОРОЙ ПРИОРИТЕТ: Аннигиляция и Удар хаоса (если Hekili их не показывает)
                if GetCVar("VadimRogueRM")=="1" then
                    -- Список приоритетных заклинаний (после артефакта)
                    local prioritySpells = {
                        {id = 227518, name = "Аннигиляция"},    -- Аннигиляция (правильный ID)
                        {id = 162794, name = "Удар хаоса"},    -- Удар хаоса
                    }
                    
                    for _, spell in ipairs(prioritySpells) do
                        if N(spell.id) == 0 then
                            CastSpellByName(spell.name)
                            return
                        end
                    end
                end
                
                -- ТРЕТИЙ ПРИОРИТЕТ: стандартная ротация, если Hekili не работает
                if GetCVar("VadimRogueRM")=="1" then
                    local spec = GetSpecialization()
                    
                    -- Для Истребления (специализация 1)
                    if spec == 1 then
                        -- Проверяем основные способности по порядку приоритета
                        local spellPriority = {
                            {id = 188499, name = "Удар клинка"},    -- Удар клинка
                            {id = 198013, name = "Пронзающий взгляд"}, -- Пронзающий взгляд
                            {id = 195072, name = "Прыжок"},         -- Прыжок
                        }
                        
                        for _, spell in ipairs(spellPriority) do
                            if N(spell.id) == 0 then
                                CastSpellByName(spell.name)
                                return
                            end
                        end
                    end
                    
                    -- Для Мести (специализация 2)
                    if spec == 2 then
                        local spellPriority = {
                            {id = 203782, name = "Срез"},           -- Срез
                            {id = 228477, name = "Рассечение душ"}, -- Рассечение душ
                            {id = 207407, name = "Резьба по душе"}, -- Резьба по душе
                        }
                        
                        for _, spell in ipairs(spellPriority) do
                            if N(spell.id) == 0 then
                                CastSpellByName(spell.name)
                                return
                            end
                        end
                    end
                end
            end
        end;

        -- Создание фрейма для постоянного обновления (вызов функции T)
        local z=CreateFrame("Frame")
        z:SetScript("OnUpdate",T)

        -- Система отложенных вызовов (таймеры)
        local Z={}  -- Таблица для хранения отложенных задач
        -- Функция добавления отложенной задачи
        local function _(time,a0,...)
            local c={...}  -- Аргументы функции
            c.func=a0;  -- Функция для выполнения
            c.time=GetTime()+time;  -- Время выполнения
            table.insert(Z,c)  -- Добавление в таблицу
        end;

        -- Функция проверки и выполнения отложенных задач
        local function a1()
            for f=#Z,1,-1 do  -- Обратный цикл для безопасного удаления
                local a2=Z[f]
                if a2.time<=GetTime() then  -- Если время пришло
                    table.remove(Z,f)  -- Удаляем задачу
                    a2.func(unpack(a2))  -- Выполняем функцию с аргументами
                end 
            end 
        end;

        -- Фрейм для обновления системы отложенных вызовов
        local g=CreateFrame("Frame")
        g:SetScript("OnUpdate",a1)  -- Проверка каждый кадр

        -- Функция отмены отложенных задач
        local function a3(a0,...)
            for f=#Z,1,-1 do 
                local a2=Z[f]
                if a2.func==a0 then  -- Если функция совпадает
                    local a4=true;
                    -- Проверка совпадения аргументов
                    for f=1,select("#",...) do 
                        if select(f,...)~=a2[f] then 
                            a4=false;
                            break 
                        end 
                    end;
                    -- Если все аргументы совпали - удаляем задачу
                    if a4 then 
                        table.remove(Z,f)
                    end 
                end 
            end 
        end;

        -- Функция включения режима ротации
        local function a5()
            if GetCVar("VadimRogueRM")=="2" then 
                SetCVar("VadimRogueRM",1)  -- Включить
            end 
        end;

        -- Обработчик событий для команд чата
        local z=CreateFrame("FRAME")
        z:SetScript("OnEvent",function(self,a6,a7)
            -- Команда /Uvolen - переключение режима ротации
            if string.match(a7,"/Uvolen") then 
                if GetCVar("VadimRogueRM")~="1" then 
                    SetCVar("VadimRogueRM",1)  -- Включить
                else 
                    SetCVar("VadimRogueRM",2)  -- Выключить
                end 
            end;
            -- Команда /p - временное выключение ротации на 0.7 секунды
            if string.match(a7,"/p") then 
                a3(a5)  -- Отменить все предыдущие вызовы a5
                a3(a5)
                a3(a5)
                a3(a5)
                if GetCVar("VadimRogueRM")=="1" then 
                    SetCVar("VadimRogueRM",2)  -- Выключить
                end;
                _(0.7,a5)  -- Запланировать включение через 0.7 секунды
            end 
        end)
        z:RegisterEvent("EXECUTE_CHAT_LINE")  -- Регистрация на событие выполнения строки чата

        -- Очистка глобальных переменных (попытка скрыть следы)
        loadstring("k,rsa,d=nil,nil,nil")()
        
        -- Module loaded successfully
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("DemonHunter rotation module loaded successfully")
        end
        return true
    end
}

-- Auto-register module when file loads
if DBM_Disease and DBM_Disease.RegisterModule then
    DBM_Disease.RegisterModule("DEMONHUNTER", DBM_Disease_Modules.DemonHunter)
    if DBM_Disease.Debug then
        DBM_Disease.Debug("DemonHunter module registered with core")
    end
end