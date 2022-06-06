raid_browser.stats = {};

-- Function wrapper around GetTalentTabInfo
local function GetTalentTabPoints(i)
	local _, _, pts = GetTalentTabInfo(i)
	return pts;
end

function raid_browser.stats.active_spec_index()
	local indices = std.algorithm.transform({1, 2, 3}, GetTalentTabPoints)
	local i, v = std.algorithm.max_of(indices);
	return i;
end

function raid_browser.stats.active_spec()
	local active_tab = raid_browser.stats.active_spec_index()
	local tab_name = GetTalentTabInfo(active_tab);
	return tab_name;
end

function raid_browser.stats.raid_lock_info(instance_name, size, difficulty,locked)
	for i = 1, #BA_SavedInstance.saved_name do
		if BA_SavedInstance.saved_name[i] == instance_name and BA_SavedInstance.saved_size[i] == size and BA_SavedInstance.difficulty[i] == difficulty and BA_SavedInstance.locked[i] == not locked
		then
			return true, BA_SavedInstance.id[i];
		end
	end

	return false, nil;
end

function raid_browser.stats.get_active_raidset()
	local spec = nil;
	local gs = nil;

	-- Retrieve gearscore if GearScoreLite is installed
	if GearScore_GetScore then
		local Name = UnitName("player")
		GearScore_GetScore(Name, "player");
		gs = GS_Data[GetRealmName()].Players[Name].GearScore
	end

	spec = raid_browser.stats.active_spec();
	return spec, gs;
end



function raid_browser.stats.build_inv_string(raid_name)
	local spec = raid_browser_character_current_raidset.spec
	local gs = raid_browser_character_current_raidset.gs
	local class = UnitClass("player");
	local message = 'пати '..spec .." ".. gs .. ', RaidBrowser';
	return message;
end