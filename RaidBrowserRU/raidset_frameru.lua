raid_browser.gui.raidset = {};

function BARaidBrowserRaidSetButton_OnClick()
	ToggleDropDownMenu(1, nil, BARaidSetDropdown, "BARaidBrowserRaidSetButton", 0, 0)
end

local info = {}

local BARaidSetDropdown = CreateFrame("Frame", "BARaidSetDropdown", LFRBrowseFrame);

BARaidSetDropdown.point = "TOPRIGHT"
BARaidSetDropdown.relativePoint = "BOTTOMRIGHT"
BARaidSetDropdown.relativeTo = "BARaidBrowserRaidSetButton"
BARaidSetDropdown.initialize = function(self, level)
	if not level then return end
	wipe(info)
	for key, raidset in ipairs(raid_browser_character_raidsets) do
		info.text = raidset.spec
		info.arg1 = key
		info.func = function(self, arg1, arg2, checked)
			raid_browser_character_current_raidset = raid_browser_character_raidsets[arg1]
			--print(arg1)
			BARaidBrowserRaidSetEditBox:SetText(raid_browser_character_current_raidset.spec)
			CloseDropDownMenus()
		end;
		UIDropDownMenu_AddButton(info);
	end
	info.text = CLOSE
	info.func = function() CloseDropDownMenus() end
	UIDropDownMenu_AddButton(info)
end

local function on_raidset_edit()
	BARaidBrowserEditSpecEditBox:SetText("Редактировать "..raid_browser_character_current_raidset.name);
	BARaidBrowserEditNameEditBox:SetText(raid_browser_character_current_raidset.spec);
	BARaidBrowserEditGearScoreEditBox:SetText(raid_browser_character_current_raidset.gs);
--	BARaidBrowserEditSpec:Show();
		if BARaidBrowserEditSpec then
		if BARaidBrowserEditSpec:IsShown() then
			BARaidBrowserEditSpec:Hide()

		else

			BARaidBrowserEditSpec:Show()
			end
	end
end



-- Create raidset save button
local button = CreateFrame("BUTTON","RaidBrowserRaidSetSaveButton", LFRBrowseFrame, "OptionsButtonTemplate")
button:SetPoint("CENTER", LFRBrowseFrame, "CENTER", -53, 168)
button:EnableMouse(true)
button:RegisterForClicks("AnyUp")

button:SetText("Редактировать");
button:SetWidth(110);
button:SetScript("OnClick", on_raidset_edit);
button:Show();
button:Enable();
BARaidBrowserEditSpec:Hide()

function BARaidBrowserEditSpecSaveButton_OnClick()
	local t1 = BARaidBrowserEditSpecEditBox:GetText()
	local t2 = BARaidBrowserEditNameEditBox:GetText()
	local t3 = BARaidBrowserEditGearScoreEditBox:GetText()
	local i = tonumber(string.sub(t1, -1, -1))
	if t2 == "" or not t1 then
		raid_browser_character_raidsets[i].spec = "Нет"
	else
		raid_browser_character_raidsets[i].spec = t2
	end
	if t3 == "" or not t3 then
		raid_browser_character_raidsets[i].gs = "nil"
	else
		raid_browser_character_raidsets[i].gs = t3
	end
	BARaidBrowserEditSpec:Hide()
end

function BARaidBrowserEditCurrentSpecButton_OnClick()
	local spec, gs = raid_browser.stats.get_active_raidset();
	BARaidBrowserEditNameEditBox:SetText(tostring(spec));
	BARaidBrowserEditGearScoreEditBox:SetText(tostring(gs));
	BARaidBrowserEditSpec:Hide()

end