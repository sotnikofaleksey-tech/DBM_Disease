-- DBM_Scanner_Performance - Оптимизация производительности
local addonName = "DBM_Scanner_Performance"

DBM_Scanner_Performance = DBM_Scanner_Performance or {}
local DSP = DBM_Scanner_Performance

DSP.performanceMode = true
DSP.updateInterval = 0.1  -- 100ms вместо 50ms
DSP.spellCheckLimit = 50  -- Проверять только 50 заклинаний

function DSP:ApplyPerformanceFixes()
    if not DBM_Scanner then return end
    
    -- Увеличиваем интервал обновления
    DBM_Scanner.castDelay = 0.15  -- 150ms между кастами
    
    -- Ограничиваем сканирование заклинаний
    if DBM_Scanner_Spells then
        DBM_Scanner_Spells.scanLimit = 20000  -- 20к вместо 500к
    end
    
    -- Оптимизируем ИИ
    if DBM_Scanner_AI then
        DBM_Scanner_AI.performanceMode = true
    end
    
    print("DBM_Scanner: Режим производительности активирован")
end

-- Команда
SLASH_DBMPERF1 = "/dbmperf"

SlashCmdList["DBMPERF"] = function()
    DSP:ApplyPerformanceFixes()
end