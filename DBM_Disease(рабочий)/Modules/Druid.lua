-- DBM_Disease Druid Module with Hekili Debug
-- IDENTICAL TO WORKING MODULES

-- Module registration
DBM_Disease_Modules = DBM_Disease_Modules or {}
DBM_Disease_Modules.Druid = {
    name = "Druid",
    class = "DRUID",
    
    Initialize = function()
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("=== Loading Druid Rotation Module ===")
        end
        
        -- Проверка: работает только для класса DRUID (друид)
        if select(2,UnitClass('player'))~='DRUID'then return end;

        local select=select;

        -- Таблица символов для генерации случайных имен (обфускация)
        local b={
        [1]="q",[2]="w",[3]="e",[4]="rR",[5]="tT",[6]="yR",[7]="u",[8]="iI",[9]="o",[10]="p",
        [11]="a",[12]="s",[13]="d",[14]="f",[15]="g",[16]="h",[17]="j",[18]="k",[19]="l",
        [20]="z",[21]="x",[22]="c",[23]="v",[24]="b",[25]="n",[26]="m",[27]="Q",[28]="W",
        [29]="E",[30]="R",[31]="T",[32]="Y",[33]="A",[34]="S",[35]="D",[36]="F",[37]="G",
        [38]="H",[39]="J",[40]="K"
        }
        local c={}
        local function d(e)
            local e=e or 8
            for f=1,e do 
                table.insert(c,b[math.random(1,#b)])
            end
            a=table.concat(c)
            return a 
        end
        local g=d(9)
        _G[g]={}
        
        -- Создание фрейма режима ротации
        _G[g].RotMode=function()
            RegisterCVar("VadimRogueRM",2)
            _G[g].RotMode=CreateFrame("Frame","Kerjn228")
            _G[g].RotMode:SetPoint("CENTER",0,-300)
            _G[g].RotMode:SetSize(60,20)
            _G[g].RotMode:SetParent(UIParent)
            _G[g].RotMode.art_f=_G[g].RotMode:CreateTexture()
            _G[g].RotMode.art_f:SetAllPoints()
            _G[g].RotMode.art_f:SetColorTexture(0,0,0,1)
            _G[g].RotMode.art_f:SetAlpha(1)
            _G[g].RotMode.ftr=_G[g].RotMode:CreateFontString(nil,"OVERLAY","QuestFont")
            _G[g].RotMode.ftr:SetPoint("CENTER",0,0)
            _G[g].RotMode.fm=CreateFrame("Frame")
            _G[g].RotMode.fm:SetScript("OnUpdate",function()
                if GetCVar("VadimRogueRM")=="1" then 
                    _G[g].RotMode.ftr:SetText("|cff00FF00Вкл|r")
                end
                if GetCVar("VadimRogueRM")=="2" then 
                    _G[g].RotMode.ftr:SetText("|cffFF0000Выкл|r")
                end 
            end)
            _G[g].RotMode:EnableMouse(true)
            _G[g].RotMode:SetMovable(true)
            _G[g].RotMode:SetUserPlaced(true)
            _G[g].RotMode:SetScript("OnMouseDown",function(self)
                self:StartMoving()
            end)
            _G[g].RotMode:SetScript("OnMouseUp",function(self)
                self:StopMovingOrSizing()
            end)
        end;
        _G[g].RotMode()

        -- Функция проверки КД
        _G[g].CDSpell=function(H)
            if select(2,GetSpellCooldown(H))+select(1,GetSpellCooldown(H))-GetTime()>0 then 
                return select(2,GetSpellCooldown(H))+select(1,GetSpellCooldown(H))-GetTime()
            else 
                return 0 
            end 
        end;

        local c="target"
        local I="player"
        local L=select(2,UnitClass(I))
        local M=CastSpellByName;
        local N=_G[g].CDSpell;

        -- Регистрация CVars
        RegisterCVar("GMMODE","0")
        RegisterCVar("VadimUnlocker2022","0")
        RegisterCVar("VadimUnlocker2022icon","0")
        RegisterCVar("VadimUnlocker2022id","0")
        RegisterCVar("HekiliDebug","0") -- Добавлен дебаг режим

        -- Таблица заклинаний
        local P={}
        for f=1,3000000 do
            if GetSpellInfo(f) and IsSpellKnown(f) then
                P[#P+1]={name=GetSpellInfo(f),icon=select(3,GetSpellInfo(f)),id=select(7,GetSpellInfo(f))}
            end 
        end;

        -- Функция поиска заклинания
        function _Get(Q)
            for R,S in pairs(P) do 
                if S.icon==Q then
                    SetCVar("VadimUnlocker2022",S.name)
                    SetCVar("VadimUnlocker2022icon",S.icon)
                    SetCVar("VadimUnlocker2022id",S.id)
                    if GetCVar("GMMODE")=="1" then 
                        local O=GetCVar("VadimUnlocker2022icon")
                        ChatFrame2:AddMessage("|T"..O..":18:18|t".." "..GetCVar("VadimUnlocker2022").." id: "..GetCVar("VadimUnlocker2022id").." icon: "..GetCVar("VadimUnlocker2022icon"))
                    end 
                end 
            end 
        end;

        -- Функция для дебага Hekili
        local function DebugHekili()
            if GetCVar("HekiliDebug") == "1" then
                ChatFrame1:AddMessage("=== HEKILI DEBUG ===")
                
                -- Проверяем все возможные фреймы Hekili
                for display = 1, 5 do
                    for button = 1, 5 do
                        local frameNames = {
                            "Hekili_D"..display.."_B"..button,
                            "HekiliD"..display.."B"..button,
                            "HekiliButton"..((display-1)*5 + button),
                            "Hekili_Button_"..display.."_"..button
                        }
                        
                        for _, frameName in ipairs(frameNames) do
                            local frame = _G[frameName]
                            if frame then
                                ChatFrame1:AddMessage("Найден фрейм: "..frameName)
                                
                                -- Проверяем текстуры
                                if frame.Texture then
                                    local texture = frame.Texture:GetTexture()
                                    ChatFrame1:AddMessage("  Текстура: "..(texture or "nil"))
                                end
                                
                                -- Проверяем другие возможные поля
                                for key, value in pairs(frame) do
                                    if type(key) == "string" and (key:find("texture") or key:find("Texture") or key:find("icon") or key:find("Icon")) then
                                        if type(value) == "table" and value.GetTexture then
                                            local tex = value:GetTexture()
                                            ChatFrame1:AddMessage("  "..key..": "..(tex or "nil"))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Проверяем глобальные таблицы Hekili
                if Hekili then
                    ChatFrame1:AddMessage("Глобальная таблица Hekili найдена")
                    if Hekili.DB then
                        ChatFrame1:AddMessage("  Hekili.DB существует")
                    end
                    if Hekili.Actions then
                        ChatFrame1:AddMessage("  Hekili.Actions существует")
                    end
                end
                
                ChatFrame1:AddMessage("=== END DEBUG ===")
            end
        end

        -- Основная функция ротации
        local function T()
            local U=GetSpecialization()
            local V=UnitAffectingCombat(I)
            
            if GetCVar("VadimRogueRM")=="2" then 
                return 
            end;
            if UnitCastingInfo(I) or UnitChannelInfo(I) then 
                return 
            end;
            if not UnitExists(c) or UnitIsDead(c) then 
                return 
            end;
            if not UnitCanAttack(I,c) then 
                return 
            end;
            if IsMounted() then 
                return 
            end;
            
            -- Для всех специализаций друида (1-4)
            if (U==1 or U==2 or U==3 or U==4) and L=="DRUID" then 
                -- Пробуем найти Hekili в различных фреймах
                local hekiliTexture = nil
                
                -- ПЕРВЫЙ ВАРИАНТ: Проверка стандартных фреймов Hekili
                for i=1,5 do
                    local frameNames = {
                        "Hekili_D1_B"..i,
                        "HekiliD1B"..i,
                        "HekiliButton"..i,
                        "Hekili_Button_1_"..i
                    }
                    
                    for _, frameName in ipairs(frameNames) do
                        local frame = _G[frameName]
                        if frame then
                            -- Пробуем разные варианты получения текстуры
                            if frame.Texture and frame.Texture.GetTexture then
                                local texture = frame.Texture:GetTexture()
                                if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                                    hekiliTexture = texture
                                    break
                                end
                            elseif frame.texture and frame.texture.GetTexture then
                                local texture = frame.texture:GetTexture()
                                if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                                    hekiliTexture = texture
                                    break
                                end
                            elseif frame.icon and frame.icon.GetTexture then
                                local texture = frame.icon:GetTexture()
                                if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                                    hekiliTexture = texture
                                    break
                                end
                            end
                        end
                    end
                    if hekiliTexture then break end
                end
                
                -- ВТОРОЙ ВАРИАНТ: Проверка других дисплеев
                if not hekiliTexture then
                    for display = 2, 3 do
                        for i=1,5 do
                            local frameNames = {
                                "Hekili_D"..display.."_B"..i,
                                "HekiliD"..display.."B"..i,
                                "Hekili_Button_"..display.."_"..i
                            }
                            
                            for _, frameName in ipairs(frameNames) do
                                local frame = _G[frameName]
                                if frame and frame.Texture then
                                    local texture = frame.Texture:GetTexture()
                                    if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                                        hekiliTexture = texture
                                        break
                                    end
                                end
                            end
                            if hekiliTexture then break end
                        end
                        if hekiliTexture then break end
                    end
                end
                
                -- ТРЕТИЙ ВАРИАНТ: Проверка через глобальную таблицу Hekili
                if not hekiliTexture and Hekili and Hekili.Actions then
                    -- Пробуем получить текущее действие из Hekili
                    for i = 1, 5 do
                        if Hekili.Actions[i] and Hekili.Actions[i].texture then
                            hekiliTexture = Hekili.Actions[i].texture
                            break
                        end
                    end
                end
                
                _G[g]._texture = hekiliTexture
                
                if GetCVar("VadimRogueRM")=="1" then 
                    if _G[g]._texture then
                        _Get(_G[g]._texture)
                        local X=GetCVar("VadimUnlocker2022")
                        local Y=tonumber(GetCVar("VadimUnlocker2022id"))
                        
                        if N(Y)==0 and X and X ~= "" and X ~= "Автоматическая атака" then
                            CastSpellByName(X)
                            return
                        end
                    else
                        -- ФОЛБЭК РОТАЦИЯ - ОСНОВНЫЕ ЗАКЛИНАНИЯ ДРУИДА ПО СПЕЦИАЛИЗАЦИЯМ
                        local spec = GetSpecialization()
                        local fallbackSpells = {}
                        
                        if spec == 1 then -- Balance
                            fallbackSpells = {
                                {id = 5176, name = "Гнев"},              -- Wrath
                                {id = 2912, name = "Звездный огонь"},    -- Starfire
                                {id = 8921, name = "Лунный огонь"},      -- Moonfire
                                {id = 194153, name = "Солнечный огонь"}, -- Sunfire
                                {id = 190984, name = "Солнечный луч"},   -- Solar Wrath
                            }
                        elseif spec == 2 then -- Feral
                            fallbackSpells = {
                                {id = 5221, name = "Разодрать"},         -- Shred
                                {id = 1822, name = "Раздирание"},        -- Rake
                                {id = 22568, name = "Яростный рев"},     -- Ferocious Bite
                                {id = 1079, name = "Разорвать"},         -- Rip
                                {id = 6785, name = "Порабощение зверя"}, -- Ravage
                            }
                        elseif spec == 3 then -- Guardian
                            fallbackSpells = {
                                {id = 33917, name = "Рык"},              -- Mangle
                                {id = 77758, name = "Медвежий рык"},     -- Thrash
                                {id = 6807, name = "Полоснуть"},         -- Maul
                                {id = 192081, name = "Железная шкура"},  -- Ironfur
                                {id = 22842, name = "Логово зверя"},     -- Frenzied Regeneration
                            }
                        elseif spec == 4 then -- Restoration
                            fallbackSpells = {
                                {id = 8936, name = "Исцеление"},         -- Healing Touch
                                {id = 774, name = "Омоложение"},         -- Rejuvenation
                                {id = 33763, name = "Цветение жизни"},   -- Lifebloom
                                {id = 48438, name = "Дикое цветение"},   -- Wild Growth
                                {id = 18562, name = "Быстрое омоложение"}, -- Swiftmend
                            }
                        else
                            fallbackSpells = {
                                {id = 5176, name = "Гнев"},
                                {id = 8921, name = "Лунный огонь"},
                                {id = 339, name = "Опутывание корнями"},
                            }
                        end
                        
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

        local z=CreateFrame("Frame")
        z:SetScript("OnUpdate",T)

        -- Система команд (ТОЧНО КАК В РАБОЧИХ МОДУЛЯХ)
        local Z={}
        local function _(time,a0,...)
            local c={...}
            c.func=a0;
            c.time=GetTime()+time;
            table.insert(Z,c)
        end;
        local function a1()
            for f=#Z,1,-1 do
                local a2=Z[f]
                if a2.time<=GetTime() then
                    table.remove(Z,f)
                    a2.func(unpack(a2))
                end 
            end 
        end;
        local g=CreateFrame("Frame")
        g:SetScript("OnUpdate",a1)
        local function a3(a0,...)
            for f=#Z,1,-1 do 
                local a2=Z[f]
                if a2.func==a0 then
                    local a4=true;
                    for f=1,select("#",...) do 
                        if select(f,...)~=a2[f] then 
                            a4=false;
                            break 
                        end 
                    end;
                    if a4 then 
                        table.remove(Z,f)
                    end 
                end 
            end 
        end;
        local function a5()
            if GetCVar("VadimRogueRM")=="2" then 
                SetCVar("VadimRogueRM",1)
            end 
        end;
        local z=CreateFrame("FRAME")
        z:SetScript("OnEvent",function(self,a6,a7)
            -- Команда /Uvolen - переключение режима ротации
            if string.match(a7,"/Uvolen") then 
                if GetCVar("VadimRogueRM")~="1" then 
                    SetCVar("VadimRogueRM",1)
                else 
                    SetCVar("VadimRogueRM",2)
                end 
            end;
            -- Команда /p - временное выключение ротации на 0.7 секунды
            if string.match(a7,"/p") then 
                a3(a5)
                a3(a5)
                a3(a5)
                a3(a5)
                if GetCVar("VadimRogueRM")=="1" then 
                    SetCVar("VadimRogueRM",2)
                end;
                _(0.7,a5)
            end;
            -- Команда /hekdebug - включение режима дебага Hekili
            if string.match(a7,"/hekdebug") then 
                if GetCVar("HekiliDebug") ~= "1" then 
                    SetCVar("HekiliDebug", "1")
                    ChatFrame1:AddMessage("Режим дебага Hekili включен")
                else 
                    SetCVar("HekiliDebug", "0")
                    ChatFrame1:AddMessage("Режим дебага Hekili выключен")
                end
                DebugHekili()
            end 
        end)
        z:RegisterEvent("EXECUTE_CHAT_LINE")
        
        loadstring("k,rsa,d=nil,nil,nil")()
        
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("Druid rotation module loaded successfully")
        end
        return true
    end
}

if DBM_Disease and DBM_Disease.RegisterModule then
    DBM_Disease.RegisterModule("DRUID", DBM_Disease_Modules.Druid)
end