-- DBM_Disease Monk Module
-- FULL ORIGINAL CODE FOR MONK - IDENTICAL STRUCTURE

-- Module registration
DBM_Disease_Modules = DBM_Disease_Modules or {}
DBM_Disease_Modules.Monk = {
    name = "Monk",
    class = "MONK",
    
    Initialize = function()
        -- Debug output
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("=== Loading Monk Rotation Module ===")
        else
            DEFAULT_CHAT_FRAME:AddMessage("DBM_Disease: Loading Monk module...")
        end
        
        -- Original code starts here - IDENTICAL STRUCTURE
        -- Проверка: работает только для класса MONK (монах)
        if select(2,UnitClass('player'))~='MONK'then return end;

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

        -- Функция проверки нахождения цели в радиусе действия заклинания
        _G[g].RCSpell=function(H,B)
            if IsSpellInRange(GetSpellInfo(H),B)==1 then 
                return true 
            else 
                return nil 
            end 
        end;

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
        local M=CastSpellByName;  -- Дублирование ссылки (избыточно)

        -- Создание таблицы всех известных игроку заклинаний
        local P={}
        for f=1,3000000 do  -- Перебор возможных ID заклинаний
            if GetSpellInfo(f) and IsSpellKnown(f) then  -- Если заклинание существует и известно
                P[#P+1]={name=GetSpellInfo(f),icon=select(3,GetSpellInfo(f)),id=select(7,GetSpellInfo(f))}  -- Сохранение данных
            end 
        end;

        -- Функция поиска заклинания по иконке и сохранения в переменные
        function _Get(Q)
            -- Преобразуем числовую текстуру в строковый путь (как в DH модуле)
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
                    -- Если включен режим отладки, выводим информацию в чат
                    if GetCVar("GMMODE")=="1" then 
                        local O=GetCVar("VadimUnlocker2022icon")
                        ChatFrame2:AddMessage("|T"..O..":18:18|t".." "..GetCVar("VadimUnlocker2022").." id: "..GetCVar("VadimUnlocker2022id").." icon: "..GetCVar("VadimUnlocker2022icon"))
                    end 
                end 
            end 
        end;

        -- Основная функция автоматической ротации
        local function T()
            local U=GetSpecialization()  -- Текущая специализация
            local V=UnitAffectingCombat(I)  -- Проверка в бою ли игрок
            if not GetCVar(K) then 
                RegisterCVar(K,"0")  -- Регистрация переменной, если не существует
            end
            -- Если специализация "Танцующий с ветром" (3) и класс "MONK"
            if U==3 and L=="MONK" then 
                _G[g].table_spell={
                    {'Сокрушающий удар',100784},
                    {'Удар тигра',100780},
                    {'Быстрое исцеление',116670},
                    {'Кулак ярости ветра',100780},
                    {'Бросок бочонка',121253},
                    {'Испускание ци',101546},
                    {'Удар летящего змея',101545},
                    {'Эликсир из концентрата дхармы',115450},
                    {'Призыв нефритовой статуи',115313},
                    {'Изгнание зла',115278},
                    {'Шквал ударов',113656},
                    {'Тотем из статуй',115313},
                    {'Порыв',115008},
                    {'Удар ногой с разворота',101545},
                    {'Жертвенная атака',115072},
                    {'Кулак ветра',100780}
                }
            end
           
            -- Если режим ротации выключен - выходим
            if GetCVar("VadimRogueRM")=="2" then 
                return 
            end;
            -- Если игрок произносит заклинание - выходим
            if UnitCastingInfo(I) or UnitChannelInfo(I) then 
                return 
            end;
            -- Если цель существует и не является врагом (пустой блок)
            if UnitExists(c) and not UnitIsEnemy(I,c) then 
            end;
            -- Если нельзя атаковать цель - выходим
            if UnitExists(c) and not UnitCanAttack(I,c) then 
                return 
            end;
            -- Если цель мертва - выходим
            if UnitExists(c) and UnitIsDead(c) then 
                return 
            end;
            -- Если игрок на транспорте - выходим
            if IsMounted() then 
                return 
            end;
            -- Если не в бою (пустой блок)
            if not V then 
            end;
            
            -- Для специализации "Танцующий с ветром" (3) - используем Hekili_D1_B1 (как в DH модуле)
            if U==3 and select(2,UnitClass('player'))=='MONK' then 
                _G[g]._texture=nil
                
                -- Пробуем найти активный фрейм Hekili (как в DH модуле)
                for j=1,5 do
                    local frameName = "Hekili_D1_B"..j
                    local frame = _G[frameName]
                    if frame and frame.Texture then
                        local texture = frame.Texture:GetTexture()
                        -- Пропускаем дефолтные текстуры (как в DH модуле)
                        if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                            _G[g]._texture = texture
                            break
                        end
                    end
                end
                
                -- Если нашли текстуру, показываем отладку
                if ChatFrame2:IsShown() and GetCVar("GMMODE")=="1" and _G[g]._texture then 
                    ChatFrame2:AddMessage("Monk Hekili |T".._G[g]._texture..":18:18|t".." "..tostring(_G[g]._texture))
                end 
            end;
            
            -- Если режим ротации включен
            if GetCVar("VadimRogueRM")=="1" then 
                if _G[g]._texture then
                    _Get(_G[g]._texture)  -- Получение информации о заклинании по текстуре
                    local X=GetCVar("VadimUnlocker2022")  -- Имя заклинания
                    local Y=tonumber(GetCVar("VadimUnlocker2022id"))  -- ID заклинания
                    
                    -- Специальные обработки для определенных заклинаний (как в шаманском модуле)
                    if _G[g]._texture==608939 and N(115078)==0 then  -- Паралич
                        return M("Паралич")
                    end;
                    if _G[g]._texture==627608 and N(115098)==0 then  -- Волна ци
                        return M("Волна ци")
                    end;
                    if _G[g]._texture==627612 and N(115072)==0 then  -- Жертвенная атака
                        return M("Жертвенная атака")
                    end;
                    if _G[g]._texture==627609 and N(116670)==0 then  -- Быстрое исцеление
                        return M("Быстрое исцеление")
                    end;
                    -- Бросок бочонка (требует указания позиции) - как тотем в шаманском модуле
                    if Y==121253 and N(Y)==0 then 
                        return RunMacroText("/cast [@cursor] Бросок бочонка")
                    end;
                    -- Применение заклинания, если оно не на КД
                    if N(Y)==0 then 
                        return M(X)  -- Применение заклинания по имени
                    end 
                else
                    -- ФОЛБЭК РОТАЦИЯ если Hekili не показывает ничего
                    if U==3 and GetCVar("VadimRogueRM")=="1" then
                        local fallbackSpells = {
                            {id = 100784, name = "Сокрушающий удар"},
                            {id = 107428, name = "Удар восходящего солнца"},
                            {id = 100780, name = "Удар тигра"},
                            {id = 101546, name = "Испускание ци"},
                        }
                        
                        for _, spell in ipairs(fallbackSpells) do
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
        z:SetScript("OnUpdate",T)  -- T будет вызываться каждый кадр
        -- Выключение режима отладки
        SetCVar("GMMODE","0")

        -- Система отложенных вызовов (таймеры) - ТОЧНО КАК В ДРУГИХ МОДУЛЯХ
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

        -- Обработчик событий для команд чата - ТОЧНО КАК В ДРУГИХ МОДУЛЯХ
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
            DBM_Disease.Debug("Monk rotation module loaded successfully")
        end
        return true
    end
}

-- Auto-register module when file loads
if DBM_Disease and DBM_Disease.RegisterModule then
    DBM_Disease.RegisterModule("MONK", DBM_Disease_Modules.Monk)
    if DBM_Disease.Debug then
        DBM_Disease.Debug("Monk module registered with core")
    end
end