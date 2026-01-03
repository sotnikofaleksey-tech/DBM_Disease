-- DBM_Disease Priest Module
-- IDENTICAL TO WORKING MODULES

-- Module registration
DBM_Disease_Modules = DBM_Disease_Modules or {}
DBM_Disease_Modules.Priest = {
    name = "Priest",
    class = "PRIEST",
    
    Initialize = function()
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("=== Loading Priest Rotation Module ===")
        end
        
        -- Проверка: работает только для класса PRIEST
        if select(2,UnitClass('player'))~='PRIEST'then return end;

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
            
            -- Для всех специализаций жреца (1-3)
            if (U==1 or U==2 or U==3) and L=="PRIEST" then 
                -- Пробуем найти Hekili в D1 фреймах
                local hekiliTexture = nil
                
                -- Проверяем D1 фреймы
                for i=1,5 do
                    local frame = _G["Hekili_D1_B"..i]
                    if frame and frame.Texture then
                        local texture = frame.Texture:GetTexture()
                        if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                            hekiliTexture = texture
                            break
                        end
                    end
                end
                
                -- Также проверяем D2 фреймы
                if not hekiliTexture then
                    for i=1,5 do
                        local frame = _G["Hekili_D2_B"..i]
                        if frame and frame.Texture then
                            local texture = frame.Texture:GetTexture()
                            if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                                hekiliTexture = texture
                                break
                            end
                        end
                    end
                end
                
                -- Также проверяем D3 фреймы
                if not hekiliTexture then
                    for i=1,5 do
                        local frame = _G["Hekili_D3_B"..i]
                        if frame and frame.Texture then
                            local texture = frame.Texture:GetTexture()
                            if texture and texture ~= "Interface\\ICONS\\Spell_Nature_BloodLust" then
                                hekiliTexture = texture
                                break
                            end
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
                        -- ФОЛБЭК РОТАЦИЯ - ОСНОВНЫЕ ЗАКЛИНАНИЯ ЖРЕЦА
                        local fallbackSpells = {
                            {id = 585, name = "Кара"},               -- Smite
                            {id = 589, name = "Слово Тьмы: Боль"},   -- Shadow Word: Pain
                            {id = 34914, name = "Прикосновение вампира"}, -- Vampiric Touch
                            {id = 8092, name = "Взрыв разума"},      -- Mind Blast
                            {id = 15407, name = "Пытка разума"},     -- Mind Flay
                            {id = 73510, name = "Призрачная стрела"}, -- Mind Spike
                            {id = 205448, name = "Видение гибели"},  -- Shadow Word: Death
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

        local z=CreateFrame("Frame")
        z:SetScript("OnUpdate",T)

        -- Система команд
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
            if string.match(a7,"/Uvolen") then 
                if GetCVar("VadimRogueRM")~="1" then 
                    SetCVar("VadimRogueRM",1)
                else 
                    SetCVar("VadimRogueRM",2)
                end 
            end;
            if string.match(a7,"/p") then 
                a3(a5)
                a3(a5)
                a3(a5)
                a3(a5)
                if GetCVar("VadimRogueRM")=="1" then 
                    SetCVar("VadimRogueRM",2)
                end;
                _(0.7,a5)
            end 
        end)
        z:RegisterEvent("EXECUTE_CHAT_LINE")
        
        loadstring("k,rsa,d=nil,nil,nil")()
        
        if DBM_Disease and DBM_Disease.Debug then
            DBM_Disease.Debug("Priest rotation module loaded successfully")
        end
        return true
    end
}

if DBM_Disease and DBM_Disease.RegisterModule then
    DBM_Disease.RegisterModule("PRIEST", DBM_Disease_Modules.Priest)
end