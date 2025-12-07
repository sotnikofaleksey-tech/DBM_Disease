local  addon, DBM_Disease = ...
local function OnAddonLoaded(event, name)
    if name == "RCLootCouncil" then
		function RCLootCouncil:DoChatHook()
			if self:IsHooked(self, "print") then  -- no function NO ERROR LMAO :D
				self:Unhook(self, "print") 
			end
		end
    end
end

DBM_Disease.Listener:Add("AddLoaded", "ADDON_LOADED", function(name, idk)
    OnAddonLoaded("ADDON_LOADED", name)
end)
