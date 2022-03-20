local registry = {}
local frame = CreateFrame('Frame')

local function printf(...) DEFAULT_CHAT_FRAME:AddMessage('|cff0061ff[RaidBrowser]: '..format(...)) end

local function script_error(type, err)
	local name, line, msg = err:match('%[string (".-")%]:(%d+): (.*)')
	printf( '%s error%s:\n %s', type,
			name and format(' in %s at line %d', name, line, msg) or '',
			err )
end

local function UnregisterOrphanedEvent(event)
	if not next(registry[event]) then
		registry[event] = nil
		frame:UnregisterEvent(event)
	end
end

BA_SavedInstance = {}
BA_SavedInstance.saved_name = {}
BA_SavedInstance.id = {}
BA_SavedInstance.saved_size = {}
BA_SavedInstance.difficulty = {}
BA_SavedInstance.locked = {}

local function OnEvent(...)
	local self, event = ...
	if event == "PLAYER_LOGIN" then
		RequestRaidInfo();
	elseif event == "UPDATE_INSTANCE_INFO" then
		wipe{BA_SavedInstance}
		for i = 1, GetNumSavedInstances() do
			local saved_name, id, reset, difficulty, locked, _, _, _, saved_size = GetSavedInstanceInfo(i);
			BA_SavedInstance.saved_name[i] = saved_name;
			BA_SavedInstance.id[i] = id;
			BA_SavedInstance.saved_size[i] = saved_size;
			BA_SavedInstance.difficulty[i] = difficulty;
			BA_SavedInstance.locked[i] = locked;
			-- print( saved_name, id, reset, difficulty, locked, _, _, _, saved_size)
		end
	elseif event == "PLAYER_ALIVE" then
		if not raid_browser_character_raidsets then
			raid_browser_character_raidsets = {}
			local spec, gs = raid_browser.stats.get_active_raidset();
--			raid_browser_character_raidsets[1] = {name="Cпек "..tostring(i),spec = spec or "?", gs = gs or "0"};
			for i=1,4 do
				raid_browser_character_raidsets[i] = {name="Спек "..tostring(i),spec = "?", gs = "0"};
			end
		end
		if not raid_browser_character_current_raidset then
			raid_browser_character_current_raidset = raid_browser_character_raidsets[1];
		end
		BARaidBrowserRaidSetEditBox:SetText(raid_browser_character_current_raidset.name)
		frame:UnregisterEvent ("PLAYER_ALIVE")
	else
		for listener,val in pairs(registry[event]) do
			local success, rv = pcall(listener[1], listener[2], select(2,...))
			if rv then
				registry[event][listener] = nil
				if not success then script_error('event callback', rv) end
			end
		end
		UnregisterOrphanedEvent(event)
	end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("UPDATE_INSTANCE_INFO")
frame:RegisterEvent("PLAYER_ALIVE")
frame:SetScript('OnEvent', OnEvent)

-- INTERFACE

function raid_browser.add_event_listener(event, callback, userparam)
	assert(callback, 'invalid callback')
	if not registry[event] then
		registry[event] = {}
		frame:RegisterEvent(event)
	end

	local listener = { callback, userparam }
	registry[event][listener] = true
	return listener
end

function raid_browser.remove_event_listener (event, listener)
	registry[event][listener] = nil
	UnregisterOrphanedEvent(event)
end