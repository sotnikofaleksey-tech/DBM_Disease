local addon, DBM_Disease = ...

DBM_Disease.toolkit = { };
toolkit = DBM_Disease.toolkit

local talentsFrame

toolkit.show_talents = function(title, talents)
    if not talentsFrame then
        -- Create the main talents frame
        talentsFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
        talentsFrame:SetSize(250, 200)
        talentsFrame:SetPoint("CENTER")
        talentsFrame:SetMovable(true)
        talentsFrame:EnableMouse(true)
        talentsFrame:RegisterForDrag("LeftButton")
        talentsFrame:SetScript("OnDragStart", talentsFrame.StartMoving)
        talentsFrame:SetScript("OnDragStop", talentsFrame.StopMovingOrSizing)
        talentsFrame.title = talentsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        talentsFrame.title:SetPoint("LEFT", talentsFrame.TitleBg, "LEFT", 5, 0)
        talentsFrame.title:SetText(title)

        -- Create a scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, talentsFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetSize(220, 160)
        scrollFrame:SetPoint("TOP", -10, -25)

        -- Create a content frame inside the scroll frame
        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(230, 600)  -- Set an initial height
        scrollFrame:SetScrollChild(content)

        -- Create label and textbox for each talent inside the content frame
        local offsetY = -10
        for i, talent in pairs(talents) do
            if talent then
                local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                label:SetPoint("TOPLEFT", 20, offsetY)
                label:SetText(talent.name .. ":")

                local textbox = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
                textbox:SetSize(50, 20)
                textbox:SetPoint("LEFT", label, "RIGHT", 10, 0)
                textbox:SetAutoFocus(false)
                textbox:SetText(talent.talent_row)

                offsetY = offsetY - 30  -- Move down for the next row
            else
                --print("No talent found for index:", i)  -- Debug line
            end
        end

        content:SetHeight(-offsetY + 10)  -- Adjust height based on how many items were added

        talentsFrame:Hide()
    end

    -- Toggle visibility
    if talentsFrame:IsShown() then
        talentsFrame:Hide()
    else
        talentsFrame:Show()
    end
end


toolkit.checkName = function()
	return UnitName("player")
end
toolkit.CheckColor = function()
	local SelectClass = select(2, UnitClass("player"));
	if SelectClass == "DEATHKNIGHT" then
		return "|cffC41E3A"
	elseif SelectClass == "DRUID" then
		return "|cffFF7C0A"
	elseif SelectClass == "HUNTER" then
		return "|cffa2e091"
	elseif SelectClass == "MAGE" then
		return "|cff3FC7EB"
	elseif SelectClass == "PALADIN" then
		return "|cffF48CBA"
	elseif SelectClass == "MONK" then
		return "|cff45d585"
	elseif SelectClass == "DEMONHUNTER" then
		return "|cff9426ea"
	elseif SelectClass == "PRIEST" then
		return "|cffFFFFFF"
	elseif SelectClass == "ROGUE" then
		return "|cffFFF468"
	elseif SelectClass == "SHAMAN" then
		return "|cff0070DD"
	elseif SelectClass == "WARLOCK" then
		return "|cff8788EE"
	elseif SelectClass == "WARRIOR" then
		return "|cffC69B6D"
	end
end
toolkit.CheckColorHex = function()
	local SelectClass = select(2, UnitClass("player"));
	if SelectClass == "DEATHKNIGHT" then -- +
		return "8c0d22"
	elseif SelectClass == "DRUID" then -- +
		return "a14f06"
	elseif SelectClass == "HUNTER" then -- +
		return "7a9653"
	elseif SelectClass == "MAGE" then -- +
		return "4d8ab3"
	elseif SelectClass == "PALADIN" then
		return "80425d"
	elseif SelectClass == "MONK" then
		return "45d585"
	elseif SelectClass == "DEMONHUNTER" then -- +
		return "4E1762"
	elseif SelectClass == "PRIEST" then  -- +
		return "7A7B7C"
	elseif SelectClass == "ROGUE" then -- ~~
		return "E6CC80"	
	elseif SelectClass == "EVOKER" then -- ~~
		return "00CCDD"
	elseif SelectClass == "SHAMAN" then  -- +
		return "0070DD"
	elseif SelectClass == "WARLOCK" then  -- +
		return "494065"
	elseif SelectClass == "WARRIOR" then -- +
		return "C69B6D"
	end
end


local builder = { }

local DiesalTools = LibStub("DiesalTools-1.0")
local DiesalStyle = LibStub("DiesalStyle-1.0")
local DiesalGUI   = LibStub("DiesalGUI-1.0")
local DiesalMenu  = LibStub("DiesalMenu-1.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Colors = DiesalStyle.Colors
local HSL, ShadeColor, TintColor = DiesalTools.HSL, DiesalTools.ShadeColor, DiesalTools.TintColor

local buttonStyleSheet = {
  ['frame-color'] = {
    type   = 'texture',
    layer  = 'BACKGROUND',
    color  = 'ffffff',
    offset = 0,
  },
  ['frame-highlight'] = {
    type     = 'texture',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'FFFFFF',
    alpha    = 0,
    alphaEnd = .1,
    offset   = -1,
  },
  ['frame-outline'] = {
    type   = 'outline',
    layer  = 'BORDER',
    color  = '000000',
    offset = 0,
  },
  ['frame-inline'] = {
    type     = 'outline',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'ffffff',
    alpha    = .02,
    alphaEnd = .09,
    offset   = -1,
  },
  ['frame-hover'] = {
    type   = 'texture',
    layer  = 'HIGHLIGHT',
    color  = 'ffffff',
    alpha  = .1,
    offset = 0,
  },
  ['text-color'] = {
    type  = 'Font',
    color = 'b8c2cc',
  },
}

local buttonStyleSheetGreen = {
  ['frame-color'] = {
    type   = 'texture',
    layer  = 'BACKGROUND',
    color  = '336d38',
    offset = 0,
  },
  ['frame-highlight'] = {
    type     = 'texture',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'FFFFFF',
    alpha    = 0,
    alphaEnd = .1,
    offset   = -1,
  },
  ['frame-outline'] = {
    type   = 'outline',
    layer  = 'BORDER',
    color  = '000000',
    offset = 0,
  },
  ['frame-inline'] = {
    type     = 'outline',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'ffffff',
    alpha    = .02,
    alphaEnd = .09,
    offset   = -1,
  },
  ['frame-hover'] = {
    type   = 'texture',
    layer  = 'HIGHLIGHT',
    color  = 'ffffff',
    alpha  = .1,
    offset = 0,
  },
  ['text-color'] = {
    type  = 'Font',
    color = 'c4ffc9',
  },
}

local buttonStyleSheetOrange = {
  ['frame-color'] = {
    type   = 'texture',
    layer  = 'BACKGROUND',
    color  = 'b57c13',
    offset = 0,
  },
  ['frame-highlight'] = {
    type     = 'texture',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'FFFFFF',
    alpha    = 0,
    alphaEnd = .1,
    offset   = -1,
  },
  ['frame-outline'] = {
    type   = 'outline',
    layer  = 'BORDER',
    color  = '000000',
    offset = 0,
  },
  ['frame-inline'] = {
    type     = 'outline',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'ffffff',
    alpha    = .02,
    alphaEnd = .09,
    offset   = -1,
  },
  ['frame-hover'] = {
    type   = 'texture',
    layer  = 'HIGHLIGHT',
    color  = 'ffffff',
    alpha  = .1,
    offset = 0,
  },
  ['text-color'] = {
    type  = 'Font',
    color = 'ffd6c6',
  },
}

local buttonStyleSheetRed = {
  ['frame-color'] = {
    type   = 'texture',
    layer  = 'BACKGROUND',
    color  = 'ff0000',
    offset = 0,
  },
  ['frame-highlight'] = {
    type     = 'texture',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'FFFFFF',
    alpha    = 0,
    alphaEnd = .1,
    offset   = -1,
  },
  ['frame-outline'] = {
    type   = 'outline',
    layer  = 'BORDER',
    color  = '000000',
    offset = 0,
  },
  ['frame-inline'] = {
    type     = 'outline',
    layer    = 'BORDER',
    gradient = 'VERTICAL',
    color    = 'ffffff',
    alpha    = .02,
    alphaEnd = .09,
    offset   = -1,
  },
  ['frame-hover'] = {
    type   = 'texture',
    layer  = 'HIGHLIGHT',
    color  = 'ffffff',
    alpha  = .1,
    offset = 0,
  },
  ['text-color'] = {
    type  = 'Font',
    color = 'ffbcbc',
  },
}

local spinnerStyleSheet = {
  ['frame-background'] = {
    type = 'texture',
    layer = 'BACKGROUND',
 --   color = '7a410b',
    gradient = {'HORIZONTAL','7a1a0b','0b7a25'},
    alpha = 1,
  },
  ['frame-inline'] = {
    type = 'outline',
    layer = 'BORDER',
    color = '000000',
    alpha = 1,
  },
  ['frame-outline'] = {
    type = 'outline',
    layer = 'BORDER',
    color = 'FFFFFF',
    alpha = 0,
    position = 1,
  },
  ['frame-hover'] = {
    type = 'outline',
    layer = 'HIGHLIGHT',
    color = 'FFFFFF',
    alpha = 1,
    position = -1,
  },
  ['editBox-font'] = {
    type = 'Font',
    color = Colors.UI_TEXT,
  },
  ['bar-background'] = {
    type = 'texture',
    layer = 'BACKGROUND',
    gradient = {'VERTICAL',Colors.UI_A100,ShadeColor(Colors.UI_A100,.1)},
  },
  ['bar-inline'] = {
    type = 'outline',
    layer = 'BORDER',
    gradient = {'VERTICAL','FFFFFF','FFFFFF'},
    alpha = {.07,.02},
  },
  ['bar-outline'] = {
    type = 'texture',
    layer = 'ARTWORK',
    color = '000000',
    alpha = .7,
    width = 1,
    position = {nil,1,0,0},
  }
}

local createButtonStyle = {
  type     = 'texture',
  layer    = 'ARTWORK',
  image    = {'DiesalGUIcons',  {1,6,16,256,128}},
  alpha    = .7,
  position = {-2,nil,-2,nil},
  width    = 16,
  height   = 16,
}

local deleteButtonStyle = {
  type     = 'texture',
  texFile  = 'DiesalGUIcons',
  texCoord = {2,6,16,256,128},
  alpha    = .7,
  offset   = {-2,nil,-2,nil},
  width    = 16,
  height   = 16,
}

local ButtonNormal = {
  type     = 'texture',
  texColor = 'ffffff',
  alpha    = .7,
}

local ButtonOver = {
  type  = 'texture',
  alpha = 1,
}

local ButtonClicked = {
  type  = 'texture',
  alpha = .3,
}

local WindowStylesheet = {
  ['frame-outline'] = {
    type  = 'outline',
    layer = 'BACKGROUND',
   -- color = 'ffaa00',
     gradient = {'VERTICAL','9A2617','ffaa00'},
	 alpha = 1,
  },
  ['frame-shadow'] = {
    type = 'shadow',
  },
  ['titleBar-color'] = {
    type  = 'texture',
    layer = 'BACKGROUND',
   -- color = 'ffaa00',
   gradient = {'HORIZONTAL','9A2617','54200a'},
    alpha = 0.6,
  },
  ['titletext-Font'] = {
    type  = 'font',
    color = 'FFFFFF',
  },
  ['closeButton-icon'] = {
    type     = 'texture',
    layer    = 'ARTWORK',
    image    = {'DiesalGUIcons', {9,5,16,256,128}, 'ff0000'},
    alpha    = .4,
    position = {-2,nil,-1,nil},
    width    = 16,
    height   = 16,
  },
  ['closeButton-iconHover'] = {
    type     = 'texture',
    layer    = 'HIGHLIGHT',
    image    = {'DiesalGUIcons', {9,5,16,256,128}, '910000'},
    alpha    = 1,
    position = {-2,nil,-1,nil},
    width    = 16,
    height   = 16,
  },
  ['header-background'] = {
    type     = 'texture',
    layer    = 'BACKGROUND',
    gradient = {'VERTICAL','4da6ff',Colors.UI_400_GR[2]},
    alpha    = .95,
    position = {0,0,0,-1},
  },
  ['header-inline'] = {
    type     = 'outline',
    layer    = 'BORDER',
    gradient = {'VERTICAL','ffffff','ffffff'},
    alpha    = {.05,.02},
    position = {0,0,0,-1},
  },
  ['header-divider'] = {
    type     = 'texture',
    layer    = 'BORDER',
    color    = '000000',
    alpha    = 1,
    position = {0,0,nil,0},
    height   = 1,
  },
  ['content-background'] = {
    type  = 'texture',
    layer = 'BACKGROUND',
   -- color = 'ffaa00',
   gradient = {'VERTICAL','54200a',DBM_Disease.toolkit.CheckColorHex()},
    alpha = 0.88,
  },
  ['content-outline'] = {
    type  = 'outline',
    layer = 'BORDER',
    color = 'FFFFFF',
    alpha = .01
  },
  ['footer-background'] = {
    type     = 'texture',
    layer    = 'BACKGROUND',
    gradient = {'VERTICAL',Colors.UI_400_GR[1],Colors.UI_400_GR[2]},
    alpha    = .95,
    position = {0,0,-1,0},
  },
  ['footer-divider'] = {
    type     = 'texture',
    layer    = 'BACKGROUND',
    color    = '000000',
    position = {0,0,0,nil},
    height   = 1,
  },
  ['footer-inline'] = {
    type     = 'outline',
    layer    = "BORDER",
    gradient = {'VERTICAL','ffffff','ffffff'},
    alpha    = {.05,.02},
    position = {0,0,-1,0},
    debug    = true,
  },
}

local checkBoxStyle = {
  base = {
    type      = 'texture',
    layer     = 'ARTWORK',
    color     = '00FF00',
    position  = -3,
  },
  disabled = {
    type      = 'texture',
    color     = '00FFFF',
  },
  enabled = {
    type      = 'texture',
    color     = Colors.UI_A400,
  },
}

DiesalGUI:RegisterObjectConstructor("FontString", function()
  local self     = DiesalGUI:CreateObjectBase(Type)
  local frame    = CreateFrame('Frame',nil,UIParent)
  local fontString = frame:CreateFontString(nil, "OVERLAY", 'PVPInfoTextFont')
  self.frame     = frame
  self.fontString  = fontString
  self.SetParent = function(self, parent)
    self.frame:SetParent(parent)
  end
  self.OnRelease = function(self)
    self.fontString:SetText('')
  end
  self.OnAcquire = function(self)
    self:Show()
  end
  self.type = "FontString"
  return self
end, 1)

DiesalGUI:RegisterObjectConstructor("Rule", function()
  local self    = DiesalGUI:CreateObjectBase(Type)
  local frame   = CreateFrame('Frame',nil,UIParent)
  self.frame    = frame
  frame:SetHeight(0.5)
  frame.texture = frame:CreateTexture()
  frame.texture:SetColorTexture(0,0,0,0.5)
  frame.texture:SetAllPoints(frame)
  self.SetParent = function(self, parent)
    self.frame:SetParent(parent)
  end
  self.OnRelease = function(self)
    self:Hide()
  end
  self.OnAcquire = function(self)
    self:Show()
  end
  self.type = "Rule"
  return self
end, 1)


DiesalGUI:RegisterObjectConstructor("Accordion", function()
    local self = DiesalGUI:CreateObjectBase(Type)
    local frame = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    self.frame = frame
    self.sections = {}
    
    self.AddSection = function(self, section)
        table.insert(self.sections, section)
        section:SetParent(self.frame)
        if #self.sections == 1 then
            section:SetPoint("TOPLEFT", self.frame, "TOPLEFT")
        else
            section:SetPoint("TOPLEFT", self.sections[#self.sections-1].frame, "BOTTOMLEFT", 0, -5)
        end
        self.frame:SetHeight(self.frame:GetHeight() + section.frame:GetHeight() + 5)
    end
    
    return self
end, 1)
 
DiesalGUI:RegisterObjectConstructor("AccordionSection", function()
    local self = DiesalGUI:CreateObjectBase(Type)
    local frame = CreateFrame('Frame', nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    frame:SetSize(200, 30)  -- начальные размеры (будут изменены)
    
    -- Header
    local header = CreateFrame('Button', nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    local headerBg = header:CreateTexture(nil, "BACKGROUND")
    headerBg:SetAllPoints(header)
    headerBg:SetColorTexture(0.2, 0.2, 0.4, 0.3)
    header.background = headerBg
	
    header:SetSize(200, 20)
    header:SetPoint("TOPLEFT")
    header:SetPoint("RIGHT")
	
	local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	headerText:SetPoint("CENTER", header, "CENTER", 0, 0) -- Center-align text
	headerText:SetJustifyH("CENTER") -- Ensure text alignment


    -- Content
    local content = CreateFrame('Frame', nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT")
    content:SetWidth(frame:GetWidth())
    content:SetHeight(0)
    
    self.frame = frame
    self.header = header
    self.content = content
    self.isCollapsed = false

    self.SetHeaderText = function(self, text)
        headerText:SetText(text)
    end

    self.Toggle = function(self)
        self.isCollapsed = not self.isCollapsed
        content:SetShown(not self.isCollapsed)
        frame:SetHeight(self.isCollapsed and 20 or (20 + content:GetHeight()))
    end

    header:SetScript('OnClick', function() self:Toggle() end)
    
    self.type = "AccordionSection"
    return self
end, 1)


local function tooltipper(ancor, tooltip_text, ...)
    local lock = ancor
    if not lock then return end
    
    -- Define the tooltip display function
    local function ShowTooltip(element)
        GameTooltip:SetOwner(lock.frame, "ANCHOR_CURSOR")
        GameTooltip:SetPoint("BOTTOM", lock.frame, "TOP", 0, 10)
        GameTooltip:SetText(tooltip_text or "", 1, 1, 1)
        GameTooltip:Show()
    end
    
    -- Define the tooltip hide function
    local function HideTooltip()
        GameTooltip:Hide()
    end
    
    -- Iterate over each element provided
    for _, elemnt in ipairs{...} do
        if elemnt then
            -- Set event listeners
            elemnt:SetScript('OnEnter', function() ShowTooltip(elemnt) end)
            elemnt:SetScript('OnLeave', HideTooltip)
        end
    end
end


local function buildElements(tbl, parent)
  -- Создаем Accordion
  local accordion = DiesalGUI:Create('Accordion')

  parent:AddChild(accordion)
  accordion.frame:SetParent(parent.content)
  accordion.frame:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, -5)
  accordion.frame:SetWidth(parent.content:GetWidth() - 10)

  local currentSection
  local offset = -5  -- смещение внутри секции
	if not currentSection then
	  currentSection = DiesalGUI:Create('AccordionSection')
	  currentSection:SetHeaderText("")
	  accordion:AddSection(currentSection)

	  currentSection.frame:SetWidth(parent.content:GetWidth() - 10)
	  currentSection.content:SetWidth(parent.content:GetWidth() - 10)
	end

  for i, element in ipairs(tbl.template) do
    local push, pull = 0, 0

    if element.type == 'section' then
      -- Если предыдущая секция уже создана – обновляем её размеры
      if currentSection then
        local finalHeight = -offset + 10  -- итоговая высота content с отступом
        currentSection.content:SetHeight(finalHeight)
        currentSection.frame:SetHeight(20 + finalHeight)  -- 20 – высота заголовка
      end
      -- Создаем новую секцию
      --currentSection = DiesalGUI:Create('AccordionSection')
	  currentSection = DiesalGUI:Create('AccordionSection')
      currentSection:SetHeaderText(element.text)
      accordion:AddSection(currentSection)
	        -- Обновляем ширину секции по ширине родительского окна
      currentSection.frame:SetWidth(parent.content:GetWidth() - 10)
      currentSection.content:SetWidth(parent.content:GetWidth() - 10)
	  -- Update width when parent resizes
	parent.content:SetScript("OnSizeChanged", function(self, width, height)
	  for i, section in ipairs(accordion.sections) do
		section.frame:SetWidth(width - 10)
		section.content:SetWidth(width - 10)
	  end
	end)

      offset = -5  -- сбрасываем смещение для новой секции

    elseif currentSection then
      if element.type == 'header' then
      local tmp = DiesalGUI:Create("FontString")
      tmp:SetParent(currentSection.content)
      currentSection:AddChild(tmp)
      tmp = tmp.fontString
      tmp:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset)
      tmp:SetText(element.text)
            if element.justify then
                tmp:SetJustifyH(element.justify)
            else
                tmp:SetJustifyH('LEFT')
            end
      tmp:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 11, "OUTLINE")
      tmp:SetWidth(currentSection.content:GetWidth()-10)

      if element.align then
        tmp:SetJustifyH(strupper(element.align))
      end

      if element.key then
        table.window.elements[element.key] = tmp
      end
      elseif element.type == 'text' then
        local tmp = DiesalGUI:Create("FontString")
        tmp:SetParent(currentSection.content)
        currentSection:AddChild(tmp)
        tmp = tmp.fontString

        local x_offset = element.x or 5
        local y_offset = element.y or offset

        tmp:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", x_offset, y_offset)
        tmp:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, y_offset)
        tmp:SetText(element.text)
        tmp:SetJustifyH('LEFT')
        tmp:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        -- Не задаем фиксированную ширину – привязка по обеим сторонам обеспечивает адаптивность

        if not element.offset then
          element.offset = tmp:GetStringHeight()
        end

        if element.align then
          tmp:SetJustifyH(strupper(element.align))
        end

        if element.key then
          tbl.window.elements[element.key] = tmp
        end

      elseif element.type == 'rule' then
 
		local tmp = DiesalGUI:Create('Rule')
		currentSection:AddChild(tmp)
		tmp:SetParent(currentSection.content)

		-- Ставим фрейм в конкретном месте
		tmp.frame:SetPoint('TOPLEFT', currentSection.content, 'TOPLEFT', 5, offset - 3)

		-- Делаем линию шириной на всю доступную область (минус отступы)
		tmp.frame:SetWidth(currentSection.content:GetWidth() - 10)
		-- Фиксируем высоту в 1 пиксель
		tmp.frame:SetHeight(1)

		-- Если нужен полупрозрачный цвет:
		-- tmp.frame.texture:SetColorTexture(0,0,0,0.5)

		if element.key then
		  tbl.window.elements[element.key] = tmp
		end

		elseif element.type == 'multi_checkbox' then
		  local checkboxes = {}

		  -- Создаем текстовую метку для группы
		  local tmp_text = DiesalGUI:Create("FontString")
		  tmp_text:SetParent(currentSection.content)
		  currentSection:AddChild(tmp_text)
		  tmp_text = tmp_text.fontString
		  tmp_text:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset+3)
		  tmp_text:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset+3)
		  tmp_text:SetText(element.text)
		  tmp_text:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
		  tmp_text:SetJustifyH('LEFT')

		  -- Получаем ширину контейнера с учетом отступов
		  local containerWidth = currentSection.content:GetWidth() - 10  -- например, отступ по 5 с каждой стороны

		  -- Начальные координаты для чекбоксов
		  local row_x = 5         -- стартовая позиция по горизонтали
		  local row_y = offset - 20  -- стартовая позиция по вертикали (можно корректировать)
		  local lineHeight = 25   -- высота строки (можно настроить)

		  for j = 1, (element.amount or 2) do
			-- Создаем чекбокс
			local checkbox = DiesalGUI:Create('Toggle')
			currentSection:AddChild(checkbox)
			checkbox:SetParent(currentSection.content)
			
			-- Создаем метку для чекбокса
			local checkbox_label = DiesalGUI:Create("FontString")
			checkbox_label:SetParent(currentSection.content)
			currentSection:AddChild(checkbox_label)
			checkbox_label = checkbox_label.fontString
			checkbox_label:SetText(element.lists[j] and element.lists[j].text or "Option " .. j)
			checkbox_label:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", (element.lists[j] and element.lists[j].size) or 11)

			-- Определяем требуемую ширину для данного чекбокса с меткой
			local cbWidth = checkbox:GetWidth() or 20  -- если метод GetWidth() не возвращает значение, можно задать оценку (например, 20)
			local labelWidth = checkbox_label:GetStringWidth() or 50
			local requiredWidth = cbWidth + 5 + labelWidth + (element.spacing or 15)

			-- Если текущая позиция + требуемая ширина превышают ширину контейнера,
			-- переходим на новую строку
			if (row_x + requiredWidth) > containerWidth then
			  row_x = 5               -- сбрасываем горизонтальную позицию
			  row_y = row_y - lineHeight  -- уменьшаем вертикальный отступ (новая строка)
			end

			-- Размещаем чекбокс и метку в текущей строке
			checkbox:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", row_x, row_y)
			checkbox_label:SetPoint("LEFT", checkbox.frame, "RIGHT", 5, 0)
			
			-- Обновляем горизонтальную позицию для следующего элемента
			row_x = row_x + requiredWidth

			-- Настраиваем сохранение и событие для чекбокса
			checkbox:SetChecked(DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key .. '_' .. j, element.default[j] or false))
			checkbox:SetEventListener('OnValueChanged', function(this, event, checked)
			  DBM_Disease.settings.store(tbl.key .. '_' .. element.key .. '_' .. j, checked)
			end)

			-- Обработчики для подсказок (tooltip)
			local function ShowTooltip()
			  GameTooltip:SetOwner(checkbox.frame, "ANCHOR_NONE")
			  GameTooltip:SetPoint("BOTTOM", checkbox.frame, "TOP", 0, 10)
			  GameTooltip:SetText(element.lists[j] and element.lists[j].tooltip or "", 1, 1, 1)
			  GameTooltip:Show()
			end
			local function HideTooltip()
			  GameTooltip:Hide()
			end
			checkbox:SetEventListener('OnEnter', ShowTooltip)
			checkbox:SetEventListener('OnLeave', HideTooltip)
			checkbox_label:SetScript("OnEnter", ShowTooltip)
			checkbox_label:SetScript("OnLeave", HideTooltip)
			
			checkboxes[j] = checkbox
		  end
		  -- После добавления всех чекбоксов обновляем смещение (offset) для следующих элементов
		  offset = row_y - 10
			  
      elseif element.type == 'checkbox' then
        local tmp = DiesalGUI:Create('Toggle')
        currentSection:AddChild(tmp)
        tmp:SetParent(currentSection.content)
        tmp:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset)
        tmp:SetEventListener('OnValueChanged', function(this, event, checked)
          DBM_Disease.settings.store(tbl.key .. '_' .. element.key, checked)
        end)

        local tmp_f = DiesalGUI:Create("FontString")
        tmp_f:SetParent(currentSection.content)
        currentSection:AddChild(tmp_f)
        tmp_f = tmp_f.fontString
        tmp_f:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 25, offset)
        -- Привязка правой стороны текстовой метки к правой стороне контейнера:
        tmp_f:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset)
        tmp_f:SetText(element.text)
        tmp_f:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        tmp.checkBoxStyle = checkBoxStyle
        tmp:SetChecked(DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key, element.default or false))
        if element.tooltip then
          tooltipper(tmp, element.tooltip, tmp_f)
        end
        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset-18)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset-18)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end
        if element.key then
          tbl.window.elements[element.key .. 'Text'] = tmp_f
          tbl.window.elements[element.key] = tmp
        end

      elseif element.type == 'spinner' then
        local tmp_spin = DiesalGUI:Create('Spinner')
        currentSection:AddChild(tmp_spin)
        tmp_spin:SetParent(currentSection.content)
        -- Привязываем правую сторону спиннера к правой стороне контейнера:
        tmp_spin:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset)
        tmp_spin:SetNumber(
          DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key, element.default)
        )
        if element.width then tmp_spin.settings.width = element.width end
        if element.min then tmp_spin.settings.min = element.min end
        if element.max then tmp_spin.settings.max = element.max end
        if element.step then tmp_spin.settings.step = element.step end
        if element.shiftStep then tmp_spin.settings.shiftStep = element.shiftStep end
        tmp_spin:ApplySettings()
        if tmp_spin.SetStylesheet then tmp_spin:SetStylesheet(spinnerStyleSheet) end
        tmp_spin:SetEventListener('OnValueChanged', function(this, event, userInput, number)
          if not userInput then return end
          DBM_Disease.settings.store(tbl.key .. '_' .. element.key, tonumber(number))
        end)

        local tmp_text = DiesalGUI:Create("FontString")
        tmp_text:SetParent(currentSection.content)
        currentSection:AddChild(tmp_text)
        tmp_text = tmp_text.fontString
        tmp_text:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset-4)
        -- Привязываем правую сторону метки к правой стороне контейнера:
        tmp_text:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset-4)
        tmp_text:SetText(element.text)
        tmp_text:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        tmp_text:SetJustifyH('LEFT')
        if element.tooltip then
          tooltipper(tmp_spin, element.tooltip, tmp_text)
        end
        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset-25)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset-25)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end
        if element.key then
          tbl.window.elements[element.key .. 'Text'] = tmp_text
          tbl.window.elements[element.key] = tmp_spin
        end

      elseif element.type == 'checkspin' then
        local tmp_spin = DiesalGUI:Create('Spinner')
        currentSection:AddChild(tmp_spin)
        tmp_spin:SetParent(currentSection.content)
        tmp_spin:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset)
        if element.width then tmp_spin.settings.width = element.width end
        if element.min then tmp_spin.settings.min = element.min end
        if element.max then tmp_spin.settings.max = element.max end
        if element.step then tmp_spin.settings.step = element.step end
        if element.shiftStep then tmp_spin.settings.shiftStep = element.shiftStep end
        tmp_spin:SetNumber(
          DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key .. '.spin', element.default_spin or 0)
        )
        if tmp_spin.SetStylesheet then tmp_spin:SetStylesheet(spinnerStyleSheet) end
        tmp_spin:ApplySettings()
        tmp_spin:SetEventListener('OnValueChanged', function(this, event, userInput, number)
          if not userInput then return end
          DBM_Disease.settings.store(tbl.key .. '_' .. element.key .. '.spin', tonumber(number))
        end)

        local tmp_check = DiesalGUI:Create('Toggle')
        currentSection:AddChild(tmp_check)
        tmp_check:SetParent(currentSection.content)
        tmp_check:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset - 2)
        tmp_check.checkBoxStyle = checkBoxStyle
        tmp_check:SetEventListener('OnValueChanged', function(this, event, checked)
          DBM_Disease.settings.store(tbl.key .. '_' .. element.key .. '.check', checked)
        end)
        local tmp_check_f = tmp_check.fontString
        tmp_check_f:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 25, offset)
        tmp_check_f:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset)
        tmp_check_f:SetText(element.text)
        tmp_check_f:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        tmp_check_f:SetJustifyH('LEFT')
        tmp_check:SetChecked(DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key .. '.check', element.default_check or false))
        if element.tooltip then
          tooltipper(tmp_spin, element.tooltip, tmp_check.fontString)
        end
        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset-18)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset-18)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end
        if element.key then
          tbl.window.elements[element.key .. 'Text'] = tmp_check_f
          tbl.window.elements[element.key .. 'Check'] = tmp_check
          tbl.window.elements[element.key .. 'Spin'] = tmp_spin
        end

      elseif element.type == 'multi_dropdown' then
        local dropdowns = {}
        local prevDropdown = nil

        local tmp_text = DiesalGUI:Create("FontString")
        tmp_text:SetParent(currentSection.content)
        currentSection:AddChild(tmp_text)
        tmp_text = tmp_text.fontString
        -- Привязываем левую сторону метки к левому краю контейнера:
        tmp_text:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset - 3)
        tmp_text:SetText(element.text)
        tmp_text:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        tmp_text:SetJustifyH('LEFT')

        for j = 1, (element.amount or 2) do
		  local tmp_list = DiesalGUI:Create('Dropdown')

		  if element.wide then
			tmp_list:SetWidth(element.wide)
		  else
			tmp_list:SetWidth(180)
		  end

		  currentSection:AddChild(tmp_list)
		  tmp_list:SetParent(currentSection.content)

		  if j == 1 then
			-- Первый дропдаун: крепим к правому краю секции
			tmp_list:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset - 5)
		  else
			-- Со 2-го и дальше: крепим к предыдущему, чтобы выстроить ряд
			tmp_list:SetPoint("RIGHT", prevDropdown.frame, "LEFT", -(element.spacing or 10), 0)
		  end

		  prevDropdown = tmp_list

          local orderedKeys = {}
          local list = {}
          for k, value in pairs(element.lists[j]) do
            orderedKeys[k] = value.key
            list[value.key] = value.text
          end
          tmp_list:SetList(list, orderedKeys)

          local default_value = element.default
          if type(default_value) == 'table' then
            default_value = default_value[j] or 'Empty'
          end

          tmp_list:SetEventListener('OnValueChanged', function(this, event, value)
            DBM_Disease.settings.store(tbl.key .. '_' .. element.key .. '_' .. j, value)
          end)
          tmp_list:SetValue(DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key .. '_' .. j, default_value))
          if element.tooltip then
            tooltipper(tmp_list, element.tooltip, tmp_text)
          end

          dropdowns[j] = tmp_list
        end

        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset - 30)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset - 30)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end

        if element.key then
          for j = 1, (element.amount or 2) do
            tbl.window.elements[element.key .. j] = dropdowns[j]
          end
        end

      elseif element.type == 'combo' or element.type == 'dropdown' then
        local tmp_list = DiesalGUI:Create('Dropdown')
        if element.width then tmp_list.settings.width = element.width end
        currentSection:AddChild(tmp_list)
        tmp_list:SetParent(currentSection.content)
        -- Привязываем dropdown к правой стороне секции:
        tmp_list:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset - 3)
        local wide = element.wide or 180
        tmp_list:SetWidth(wide)
        local orderdKeys = {}
        local list = {}
        for j, value in pairs(element.list) do
          orderdKeys[j] = value.key
          list[value.key] = value.text
        end
        tmp_list:SetList(list, orderdKeys)
        tmp_list:SetEventListener('OnValueChanged', function(this, event, value)
          DBM_Disease.settings.store(tbl.key .. '_' .. element.key, value)
        end)
        tmp_list:SetValue(DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key, element.default))

        local tmp_text = DiesalGUI:Create("FontString")
        tmp_text:SetParent(currentSection.content)
        currentSection:AddChild(tmp_text)
        tmp_text = tmp_text.fontString
        tmp_text:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset - 3)
        -- Привязываем правую сторону метки к левой стороне dropdown'а:
        tmp_text:SetPoint("TOPRIGHT", tmp_list.frame, "TOPLEFT", -5, offset - 3)
        tmp_text:SetText(element.text)
        tmp_text:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        tmp_text:SetJustifyH('LEFT')
		  tmp_text:SetWordWrap(false)  -- Отключаем перенос текста
        if element.tooltip then
          tooltipper(tmp_list, element.tooltip, tmp_text)
        end
        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset - 25)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset - 25)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end
        if element.key then
          tbl.window.elements[element.key .. 'Text'] = tmp_text
          tbl.window.elements[element.key] = tmp_list
        end

      elseif element.type == 'button' then
        local tmp = DiesalGUI:Create("Button")
        element.height = element.height or 20
        currentSection:AddChild(tmp)
        tmp:SetParent(currentSection.content)
        tmp:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5 + (element.offset_y or 0), offset)
        tmp:SetText(element.text)
        tmp:SetWidth(element.width or currentSection.content:GetWidth() - 10)
        tmp:SetHeight(element.height or 20)
        tmp.buttonStyleSheetGreen = buttonStyleSheetGreen
        tmp.buttonStyleSheetRed = buttonStyleSheetRed
        tmp.buttonStyleSheetOrange = buttonStyleSheetOrange
        if tmp.SetStylesheet then tmp:SetStylesheet(buttonStyleSheetGreen) end
        if element.call then
          element.callback(tmp, 'OnStyle')
        end
        tmp:SetEventListener("OnClick", element.callback)
        if element.tooltip then
          tooltipper(tmp, element.tooltip)
        end
        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset - element.height - 3)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset - element.height - 3)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end
        if element.align then
          tmp:SetJustifyH(strupper(element.align))
        end
        if element.key then
          tbl.window.elements[element.key] = tmp
        end

      elseif element.type == "input" then
        local tmp_input = DiesalGUI:Create('Input')
        currentSection:AddChild(tmp_input)
        tmp_input:SetParent(currentSection.content)
        tmp_input:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset)
        if element.width then
          tmp_input:SetWidth(element.width)
        end
        tmp_input:SetText(DBM_Disease.settings.fetch(tbl.key .. '_' .. element.key, element.default or ''))
        tmp_input:SetEventListener('OnEditFocusLost', function(this)
          DBM_Disease.settings.store(tbl.key .. '_' .. element.key, this:GetText())
        end)

        local tmp_text = DiesalGUI:Create("FontString")
        tmp_text:SetParent(currentSection.content)
        currentSection:AddChild(tmp_text)
        tmp_text = tmp_text.fontString
        tmp_text:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset-3)
        tmp_text:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset-3)
        tmp_text:SetText(element.text)
        tmp_text:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", element.size or 9)
        tmp_text:SetJustifyH('LEFT')
        if element.tooltip then
          tooltipper(tmp_input, element.tooltip, tmp_text)
        end
        if element.desc then
          local tmp_desc = DiesalGUI:Create("FontString")
          tmp_desc:SetParent(currentSection.content)
          currentSection:AddChild(tmp_desc)
          tmp_desc = tmp_desc.fontString
          tmp_desc:SetPoint("TOPLEFT", currentSection.content, "TOPLEFT", 5, offset-25)
          tmp_desc:SetPoint("TOPRIGHT", currentSection.content, "TOPRIGHT", -5, offset-25)
          tmp_desc:SetText(element.desc)
          tmp_desc:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9)
          push = tmp_desc:GetStringHeight() + 5
        end
        if element.key then
          tbl.window.elements[element.key .. 'Text'] = tmp_text
          tbl.window.elements[element.key] = tmp_input
        end

      elseif element.type == 'spacer' then
        -- Ничего не создаем
      end

      if element.push then push = push + element.push end
      if element.pull then pull = pull + element.pull end
      offset = offset - push + pull

      if element.type == 'rule' then
        offset = offset - 10
      elseif element.type == 'spinner' or element.type == 'checkspin' or element.type == 'checkbox' then
        offset = offset - 25
      elseif element.type == 'combo' or element.type == 'dropdown' or element.type == 'multi_dropdown' then
        offset = offset - 22
      elseif element.type == 'texture' then
        offset = offset - (element.offset or 0)
      elseif element.type == "text" then
        offset = offset - (element.offset or 0)
      elseif element.type == 'button' then
        offset = offset - 20
      elseif element.type == 'multi_checkbox' then
        offset = offset - (element.size or 20)
      elseif element.type == 'spacer' then
        offset = offset - (element.size or 10)
      else
        offset = offset - 16
      end
    end
  end

  -- Завершаем последнюю секцию, если она есть
  if currentSection then
    local finalHeight = -offset + 10
    currentSection.content:SetHeight(finalHeight)
    currentSection.frame:SetHeight(20 + finalHeight)
  end
end

function builder.buildGUI(template)
  local parent = DiesalGUI:Create('Window')
  parent:SetStylesheet(WindowStylesheet)
  parent:SetWidth(template.width or 200)
  parent:SetHeight(template.height or 300)

  if not template.key_orig then
    template.key_orig = template.key
  end

   if template.profiles == true and template.key_orig then
    parent.settings.footer = true

    local createButton = DiesalGUI:Create('Button')
    parent:AddChild(createButton)
    createButton:SetParent(parent.footer)
    createButton:SetPoint('TOPLEFT',17,-1)
    createButton:SetSettings({
      width   = 20,
      height    = 20,
    }, true)
    createButton:SetText('+')
    createButton:SetStylesheet(createButtonStyle)
    createButton:SetEventListener('OnClick', function()

      local newWindow = DiesalGUI:Create('Window')
      parent:AddChild(newWindow)
      newWindow:SetTitle("Create Profile")
      newWindow.settings.width = 200
      newWindow.settings.height = 75
      newWindow.settings.minWidth = newWindow.settings.width
      newWindow.settings.minHeight = newWindow.settings.height
      newWindow.settings.maxWidth = newWindow.settings.width
      newWindow.settings.maxHeight = newWindow.settings.height
      newWindow:ApplySettings()

      local profileInput = DiesalGUI:Create('Input')
      newWindow:AddChild(profileInput)
      profileInput:SetParent(newWindow.content)
      profileInput:SetPoint("TOPLEFT", newWindow.content, "TOPLEFT", 5, -5)
      profileInput:SetPoint("BOTTOMRIGHT", newWindow.content, "TOPRIGHT", -5, -25)
      profileInput:SetText("New Profile Name")

      local profileButton = DiesalGUI:Create('Button')
      newWindow:AddChild(profileButton)
      profileButton:SetParent(newWindow.content)
      profileButton:SetPoint("TOPLEFT", newWindow.content, "TOPLEFT", 5, -30)
      profileButton:SetPoint("BOTTOMRIGHT", newWindow.content, "TOPRIGHT", -5, -50)
      if profileButton.SetStylesheet then profileButton:SetStylesheet(buttonStyleSheetGreen) end
      profileButton:SetText("Create New Profile")
      profileButton:SetEventListener('OnClick', function()

        local profiles = DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profiles', {{key='default',text='Default'}})
        local profileName = profileInput:GetText()
        local pkey = string.gsub(profileName, "%s+", "")
        if profileName ~= '' then
          for _,p in ipairs(profiles) do
            if p.key == pkey then
              profileButton:SetText('|cffff3300Profile with that name exists!|r')
              C_Timer.NewTicker(2, function()
                profileButton:SetText("Create New Profile")
              end, 1)
              return false
            end
          end
          table.insert(profiles, { key = pkey, text = profileName })
          DBM_Disease.settings.store(template.key_orig .. '_' .. 'profiles', profiles)
          DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', pkey)
          newWindow:Hide()
          parent:Hide()
          parent:Release()
          builder.buildGUI(template)
        end

      end)
      profileInput:SetEventListener("OnEnterPressed", function()

        local profiles = DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profiles', {{key='default',text='Default'}})
        local profileName = profileInput:GetText()
        local pkey = string.gsub(profileName, "%s+", "")
        if profileName ~= '' then
          for _,p in ipairs(profiles) do
            if p.key == pkey then
              profileButton:SetText('|cffff3300Profile with that name exists!|r')
              C_Timer.NewTicker(2, function()
                profileButton:SetText("Create New Profile")
              end, 1)
              return false
            end
          end
          table.insert(profiles, { key = pkey, text = profileName })
          DBM_Disease.settings.store(template.key_orig .. '_' .. 'profiles', profiles)
          DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', pkey)
          newWindow:Hide()
          parent:Hide()
          parent:Release()
          builder.buildGUI(template)
        end

      end)

    end)
    createButton:SetEventListener('OnEnter', function()
      createButton:SetStyle('frame', ButtonOver)
    end)
    createButton:SetEventListener('OnLeave', function()
      createButton:SetStyle('frame', ButtonNormal)
    end)
    createButton.frame:SetScript('OnMouseDown', function()
      createButton:SetStyle('frame', ButtonNormal)
    end)
    createButton.frame:SetScript('OnMouseUp', function()
      createButton:SetStyle('frame', ButtonOver)
    end)

    local deleteButton = DiesalGUI:Create('Button')
    parent:AddChild(deleteButton)
    deleteButton:SetParent(parent.footer)
    deleteButton:SetPoint('TOPLEFT',0,-1)
    deleteButton:SetSettings({
      width     = 20,
      height    = 20,
    }, true)
    deleteButton:SetText('-')
    deleteButton:SetStylesheet(deleteButtonStyle)
    deleteButton:SetEventListener('OnEnter', function()
      deleteButton:SetStyle('frame', ButtonOver)
    end)
    deleteButton:SetEventListener('OnLeave', function()
      deleteButton:SetStyle('frame', ButtonNormal)
    end)
    deleteButton.frame:SetScript('OnMouseDown', function()
      deleteButton:SetStyle('frame', ButtonNormal)
    end)
    deleteButton.frame:SetScript('OnMouseUp', function()
      deleteButton:SetStyle('frame', ButtonOver)
    end)
    deleteButton:SetEventListener('OnClick', function()
      local selectedProfile = DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profile', 'Default Profile')
      local profiles = DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profiles', {{key='default',text='Default'}})
      if selectedProfile ~= 'default' then
        for i,p in ipairs(profiles) do
          if p.key == selectedProfile then
            profiles[i] = nil
            DBM_Disease.settings.store(template.key_orig .. '_' .. 'profiles', profiles)
            DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', 'default')
            parent:Hide()
            parent:Release()
            builder.buildGUI(template)
          end
        end
      else
        engine.alert.Notify("WaterHack", "Cannot delete default profile!")
      end
    end)

    local profiles = DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profiles', {{key='default',text='Default'}})
    local selectedProfile = DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profile', 'default')
    local profile_dropdown = DiesalGUI:Create('Dropdown')
    parent:AddChild(profile_dropdown)
    profile_dropdown:SetParent(parent.footer)
    profile_dropdown:SetPoint("TOPRIGHT", parent.footer, "TOPRIGHT", 1, 0)
    profile_dropdown:SetPoint("BOTTOMLEFT", parent.footer, "BOTTOMLEFT", 37, -1)

    local orderdKeys = { }
    local list = { }

    for i, value in pairs(profiles) do
      orderdKeys[i] = value.key
      list[value.key] = value.text
    end

    profile_dropdown:SetList(list, orderdKeys)

    -- profile_dropdown:SetEventListener('OnValueChanged', function(this, event, value)
    --   if selectedProfile ~= value then
    --     DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', value)
    --     parent:Hide()
    --     parent:Release()
    --     builder.buildGUI(template)
    --   end
    -- end)

    profile_dropdown:SetValue(DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'profile', 'Default Profile'))
    --function whChangedProfile(thisprofile)
    --  profile_dropdown:SetValue(DBM_Disease.settings.fetch(template.key_orig . .. '_' .. '.' .. thisprofile))
    --  if string.lower(list[thisprofile]) ~= string.lower(thisprofile) then
    --    return engine.alert.Notify("WaterHack", "Profile does not exist!")
    --  end
    --    --DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', thisprofile)
    --  parent:Hide()
    --  parent:Release()
    --  builder.buildGUI(template)
    --  engine.alert.Notify("WaterHack", "Changed profile to: "..thisprofile.."!")
    --end
    if selectedProfile then
      template.key = template.key_orig .. '.' .. selectedProfile
    end

    profile_dropdown:SetEventListener('OnValueChanged', function(this, event, value)
      if selectedProfile ~= value then
        DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', value)
		DBM_Disease.settings.store('prflv', value)
        parent:Hide()
        parent:Release()
        builder.buildGUI(template)
      end
    end)

  else
    DBM_Disease.settings.store(template.key_orig .. '_' .. 'profile', false)
  end



  if template.key_orig then
    parent:SetEventListener('OnDragStop', function(self, event, left, top)
      DBM_Disease.settings.store(template.key_orig .. '_' .. 'window', {left, top})
    end)
    local left, top = unpack(DBM_Disease.settings.fetch(template.key_orig .. '_' .. 'window', {false, false}))
    if left and top then
      parent.settings.left = left
      parent.settings.top = top
      parent:UpdatePosition()
    end
  end
  
  local window = DiesalGUI:Create('ScrollFrame')
  parent:AddChild(window)
  window:SetParent(parent.content)
  window:SetAllPoints(parent.content)
  window.parent = parent

  if not template.color then template.color = DBM_Disease.color end
  spinnerStyleSheet['bar-background']['gradient'] = { 'VERTICAL', 'AE5E62', ShadeColor('AE5E62',.1) }
  checkBoxStyle['enabled']['color'] = '3ad435'

  if template.title then
    parent:SetTitle("|cff"..'e0dede'..template.title.."|r", template.subtitle)
  end
  if template.width then
    parent:SetWidth(template.width)
  end
  if template.height then
    parent:SetHeight(template.height)
  end
  if template.minWidth then
    parent.settings.minWidth = template.minWidth
  end
  if template.minHeight then
    parent.settings.minHeight = template.minHeight
  end
  if template.maxWidth then
    parent.settings.maxWidth = template.maxWidth
  end
  if template.maxHeight then
    parent.settings.maxHeight = template.maxHeight
  end
  if template.resize == false then
    parent.settings.minHeight = template.height
    parent.settings.minWidth = template.width
    parent.settings.maxHeight = template.height
    parent.settings.maxWidth = template.width
  end

  parent:ApplySettings()

  template.window = window

  window.elements = { }

  buildElements(template, window)

  parent.frame:SetClampedToScreen(true)

  if template.show then
    parent.frame:Show()
  else
    parent.frame:Hide()
  end

  return window

end

DBM_Disease.interface.builder = builder



if (GetLocale() == "ruRU") then
 L_Pst = 'Производительность'
 L_TickRate = 'Тик-Рейт'
 L_GCDC =  'Проверка на гкд'
 L_btnnotify =  'Notify кнпк'
 L_Turbo = 'Турбо'
 L_CLIP = 'Клип'
 L_HookCast = 'Очередь спелов'
 L_HookCastDesc = 'Добавить спелл в очередь по клику'

 L_TickRateDesc = 'Тикрейт ротации в секундах. [0.1 Деф.]'
 L_GCDCDesc = 'Ставить ротацию на паузу при гкд.'
 L_btnnotifyDesc = 'В режиме hide показывать переключение кнопки.'
 L_TurboDesc = 'Турбо режим.' -- turbo
 L_CLIPDesc = 'Время в секундах, перед попыткой скастить спелл при гкд. [0.15 Деф.]'

 L_TKhello = 'Привет'
 L_TKserver = 'Твой сервер'
 L_TKluck = 'Удачи'
 else
 L_Pst = 'Performance'
 L_TickRate = 'Tick Rate'
 L_GCDC =  'Btn toggle notify'
 L_btnnotify =  'GCD Check'
 L_Turbo = 'Turbo'
 L_CLIP = 'Clip'
 L_HookCast = 'Spell que hook'
 L_HookCastDesc = 'add to que spell by click'

 L_TickRateDesc = 'The core ticket rate, in seconds.  Default is 0.1'
 L_GCDCDesc = 'Attempt to pause the rotation during the GCD.'
 L_btnnotifyDesc = 'Show notify on btn tggle in hide mode.'
 L_TurboDesc = 'Enables higher performance.' -- turbo
 L_CLIPDesc = 'The amount of time, in seconds, before attempting the next cast during the GCD.  Default is 0.15'

 L_TKhello = 'Greatings'
 L_TKserver = 'Your server'
 L_TKluck = 'GL HF'
 end

DBM_Disease.on_ready(function()
  local engine = {
    key = "_engine",
    title = 'DBM_Disease',
    subtitle = 'Build ' .. DBM_Disease.version,
    color = '1F8FB5',
    profiles = false,
    width = 250,
    height = 300,
    resize = true,
    show = true,
    template = {
      { type = 'header', text = L_Pst },
      { type = 'rule' },
      { key = 'hookCast', type = 'checkbox', text = L_HookCast, desc = L_HookCastDesc, default = true },
      { type = 'rule' },
      { key = 'tickrate', type = 'spinner', text = L_TickRate, desc = L_TickRateDesc, min = 0.01, max = 1.00, step = 0.05, default = 0.2, width=88 }, 
      { key = 'gcd', type = 'checkbox', text = L_GCDC, desc = L_GCDCDesc, default = true },
      { key = 'btnnotify', type = 'checkbox', text = L_btnnotify, desc = L_btnnotifyDesc, default = false },
      { type = 'spacer' },
      { type = 'header', text = L_Turbo .. " [Deprecated]" },
      { type = 'rule' },
      { type = 'text', text = "Not work do not use." },
      { key = 'turbo', type = 'checkbox', text = L_Turbo, desc = L_TurboDesc, default = false },
      { key = 'castclip', type = 'spinner', text = L_CLIP, desc = L_CLIPDesc, min = 0.00, max = 1.00, step = 0.01, default = 0.15, width=88 },
    }
  }
  configWindow = builder.buildGUI(engine)
  configWindow.parent:Hide()
  DBM_Disease.econf = configWindow
end)

DBM_Disease.on_ready(function()
  local _bl = {
    key = "_bl",
    title = 'Nah-ah',
    subtitle = 'No healing for you today.',
    color = '1F8FB5',
    profiles = false,
    width = 650,
    height = 300,
    resize = true,
    show = true,
    template = {
      { type = 'header', text = "Player name to blacklist from healing." },
      { type = 'rule' },
      { type = "input", key = "inputkey", text = "",desc="Name1; Name2; Name3; ...", width = 545.0 },
    }
  }
  configWindow = builder.buildGUI(_bl)
  configWindow.parent:Hide()
  DBM_Disease._blacklisted = configWindow
end)

toolkit.PlayedServer = function()
	return GetRealmName()
end
toolkit.ChatMessage = function()
	print("=======================================")
	print("- "..L_TKhello.." " ..toolkit.CheckColor()..toolkit.checkName(),"!")
	print("- "..L_TKserver.." - |cffFFFF00" ..toolkit.PlayedServer())		
	print("- "..L_TKluck.." :D")
	print("=======================================")
end
local UIParent = UIParent
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local PlaySound = PlaySound

-- Splash --

local FrameBackdrop = {
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 14,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
local SilentSplasher = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)

SilentSplasher:SetBackdrop(FrameBackdrop)
SilentSplasher:SetBackdropColor(0, 0, 0, 1)

SilentSplasher.texture = SilentSplasher:CreateTexture()
SilentSplasher.texture:SetPoint("LEFT",2,0)
SilentSplasher.texture:SetSize(95,95)

SilentSplasher.text = SilentSplasher:CreateFontString(nil, "OVERLAY", "MovieSubtitleFont");
SilentSplasher.text:SetPoint("RIGHT",-4,0)
SilentSplasher:Hide()
local function Ticker(self)
  local Alpha = SilentSplasher:GetAlpha()
  SilentSplasher:SetAlpha(Alpha-.008)
  if Alpha <= 0.05177 then
    SilentSplasher:Hide()
    self:Cancel()
  end
end
local function SpecIcon()
  local currentSpec = GetSpecialization()
  return select(4,GetSpecializationInfo(currentSpec))
end
function Splash(txt, icon, time)
 local  icon = icon or SpecIcon()
  local time = time or 5
	SilentSplasher:SetAlpha(1)
	SilentSplasher:Show()
	PlaySound(124, "SFX");
	SilentSplasher.texture:SetTexture(icon)
	SilentSplasher.text:SetText(txt)
	local Width = SilentSplasher.text:GetStringWidth()+SilentSplasher.texture:GetWidth()+8
	SilentSplasher:SetSize(Width,100)
	SilentSplasher:SetPoint("CENTER",0,435	)
  C_Timer.NewTicker(time/100, Ticker, nil)
end

local function login()
if (GetLocale() == "ruRU") then
	C_Timer.After(7.5, function() Splash('Напиши /fdh и узнаешь как влючить всё.', _, 15) end)
		else 
    C_Timer.After(7.5, function() Splash('Type /fdh !', _, 15) end)
end
end


local function OnEvent(self, event, isLogin, isReload)
if isLogin or isReload then
	local container_frame = DBM_Disease.container_frame
    local stateval = DBM_Disease.settings.fetch('ssc')

	if stateval == 1 then
		container_frame:Hide()
	end
	if stateval == 2 then
	-- login()
		toolkit.ChatMessage()
		PlaySoundFile([[Interface\AddOns\Feral\Butwhy\Core\media\hai.ogg]], "SFX")  					  
		container_frame:Show()
	end
end
if isLogin then
					local container_frame = DBM_Disease.container_frame
					local container_frame2 = UIPanelButtonTemplateTest
					local stateval = DBM_Disease.settings.fetch('ssc')
					  if stateval == 1 then
						container_frame:Hide()
					  end
					  if stateval == 2 then
					  container_frame:Show()
					  end
end
end

local _c = CreateFrame("Frame");_c:RegisterEvent("PLAYER_ENTERING_WORLD");_c:SetScript("OnEvent", OnEvent)
