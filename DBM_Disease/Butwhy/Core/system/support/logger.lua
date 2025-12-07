local addon, DBM_Disease = ...

DBM_Disease.console = {
  debugLevel = 0,
  file = '',
  line = ''
}

local fontObject = CreateFont("DBM_Disease_console")
fontObject:SetFont("Interface\\Addons\\DBM_Disease\\Butwhy\\Core\\media\\Furore.otf", 9, "")

local consoleFrame = CreateFrame('ScrollingMessageFrame', DBM_Disease.string_random(12), UIParent)


consoleFrame:SetFontObject("DBM_Disease_console")

-- position and setup
consoleFrame:SetPoint('CENTER', UIParent)
consoleFrame:SetMaxLines(1000)
consoleFrame:SetInsertMode('BOTTOM')
consoleFrame:SetWidth(500)
consoleFrame:SetHeight(745)
consoleFrame:SetJustifyH('LEFT')
consoleFrame:SetFading(false)
consoleFrame:SetClampedToScreen(true)
consoleFrame:Hide()

-- setup background
consoleFrame.background = consoleFrame:CreateTexture('background')
consoleFrame.background:SetPoint('TOPLEFT', consoleFrame, 'TOPLEFT', -5, 5)
consoleFrame.background:SetPoint('BOTTOMRIGHT', consoleFrame, 'BOTTOMRIGHT', 5, -5)
consoleFrame.background:SetColorTexture(0, 0, 0, 0.45)

consoleFrame.background2 = consoleFrame:CreateTexture('background')
consoleFrame.background2:SetPoint('TOPLEFT', consoleFrame, 'TOPLEFT', -7, 7)
consoleFrame.background2:SetPoint('BOTTOMRIGHT', consoleFrame, 'BOTTOMRIGHT', 7, -7)
consoleFrame.background2:SetColorTexture(20/255, 20/255, 20/255, 0.4)

-- make draggable
consoleFrame:SetMovable(true)
consoleFrame:EnableMouse(true)
consoleFrame:RegisterForDrag('LeftButton')
consoleFrame:SetScript('OnDragStart', consoleFrame.StartMoving)
consoleFrame:SetScript('OnDragStop', consoleFrame.StopMovingOrSizing)

-- scrolling
consoleFrame:SetScript('OnMouseWheel', function(self, delta)
    if delta > 0 then
        if IsShiftKeyDown() then
            self:ScrollToTop()
        else
            self:ScrollUp()
        end
    else
        if IsShiftKeyDown() then
            self:ScrollToBottom()
        else
            self:ScrollDown()
        end
    end
end)

-- display frame
function DBM_Disease.console.set_level(level)
  level = tonumber(level) or 0
  DBM_Disease.console.debugLevel = level
  DBM_Disease.settings.store('debug_level', level)
end

function DBM_Disease.console.toggle(show)
  show = show
  DBM_Disease.settings.store('debug_show', show)
  if show then
    consoleFrame:Show()
  else
    consoleFrame:Hide()
  end
end

local function join(...)
    local ret = ''
    for n = 1, select('#', ...) do
        ret = ret .. ', ' .. tostring(select(n, ...))
    end
    return ret:sub(3)
end

local colorize = DBM_Disease.interface.colorize
local last = false
function DBM_Disease.console.log_time(str)
  local at = date('%H:%M:%S', C_DateAndTime.GetServerTimeLocal())
  local joined = string.format('%s %s', at, str)
  if last ~= joined then
    DBM_Disease.console.log(joined)
    last = joined
  end
end

function DBM_Disease.console.log(...)
    consoleFrame:AddMessage(...)
end

function DBM_Disease.console.notice(...)
  DBM_Disease.console.log(date('%H:%M:%S', time())..'|cff91FF00[notice]|r ' .. join(...))
end

function DBM_Disease.console.debug(level, section, color, ...)
  if DBM_Disease.console.debugLevel >= level then
    DBM_Disease.console.log_time(
      string.format(
        '%s %s',
        colorize(color, '[' .. section .. ']'),
        join(...)
      )
    )
  end
end

function DBM_Disease.log(string, ...)
  local formatted = string.format(string, ...)
  print('|cff' .. DBM_Disease.color .. '[DBM_Disease]|r ' .. formatted)
end

function DBM_Disease.error(...)
  print('|cff' .. DBM_Disease.color .. '[DBM_Disease]|r |cffc32425' .. join(...) .. '|r')
end

local function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function DBM_Disease.format(value)
  if tonumber(value) then
    return round(value, 2)
  else
    return tostring(value)
  end
end

DBM_Disease.on_ready(function()
  local debug_level = DBM_Disease.settings.fetch('debug_level', nil)
  DBM_Disease.console.set_level(debug_level)
  local toggle = DBM_Disease.settings.fetch('debug_show', false)
  DBM_Disease.console.toggle(toggle)
  DBM_Disease.console.log("Welcome!")
end)


