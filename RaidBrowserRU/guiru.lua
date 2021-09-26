
local addonName, vars = ...
local L = vars.L
if AceLibrary:HasInstance("FuBarPlugin-2.0") then
	RaidBrowser = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceDB-2.0","AceEvent-2.0","FuBarPlugin-2.0")
else
	RaidBrowser = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceDB-2.0","AceEvent-2.0")
end
_G = _G

local TITLE = rbTitle


local addon = RaidBrowser
addon.vars = vars
-------------------------------------------
-------
-------- создаем  мини кнопку и саму панель v2
--------
----------
----------- 

-- FuBar stuff
addon.name = "RaidBrowser"
addon.hasIcon = true
addon.hasNoColor = true
addon.clickableTooltip = false
addon.independentProfile = true
addon.cannotDetachTooltip = true
addon.hideWithoutStandby = true





function addon:OnTextUpdate()
	self:SetText("RaidBrowser")
  local f = addon.minimapFrame; 
  if f then -- ticket #14
    f.SetFrameStrata(f,"MEDIUM") -- ensure the minimap icon isnt covered by others 	
  end
end

-- AceDB stuff
addon:RegisterDB("RaidBrowserDB")
addon:RegisterDefaults("profile", {


	})

-- ACE options menu
local options = {
  type = 'group',
  handler = RaidBrowser,
--  args = {},
	
  --settings = {},
 }

 addon.OnMenuRequest = options



local SLDB

function addon:OnEnable()

  self:OnProfileEnable()
  
  

  if SLDB then
    return
  end
  if AceLibrary:HasInstance("LibDataBroker-1.1") then
    SLDB = AceLibrary("LibDataBroker-1.1")
  elseif LibStub then
    SLDB = LibStub:GetLibrary("LibDataBroker-1.1",true)
  end
  if SLDB then
    local dataobj = SLDB:GetDataObjectByName("RaidBrowser") or 
      SLDB:NewDataObject("RaidBrowser", {
        type = "launcher",
        label = "RaidBrowser",
        icon = "Interface\\AddOns\\RaidBrowser\\icon",
      })
			 dataobj.OnClick = function(self, button)
								if button == "RightButton" then
										RaidBrowser:OpenMenu(self,addon)
								else
										RaidBrowser:Togglelfrwindow()
								end
             end    
			dataobj.OnTooltipShow = function(tooltip)
				if tooltip and tooltip.AddLine then
						tooltip:SetText("RaidBrowser")
						tooltip:AddLine(L["|cffff8040Left Click|r to toggle the window"])
						tooltip:AddLine(L["|cffff8040Right Click|r for menu"])
						tooltip:Show()
				end
            end            

  end  

  end

function addon:OnProfileDisable()
    end

function addon:OnProfileEnable()
    end

function addon:OnClick(button)

	if LFRParentFrame then
		if LFRParentFrame:IsShown() then
			LFRParentFrame:Hide()
			
		else
			
			LFRParentFrame:Show()
			end
	end
	LFRBrowseFrameRefreshButton:Hide()
end

function addon:Togglelfrwindow()
	if LFRParentFrame then
		if LFRParentFrame:IsShown() then
			LFRParentFrame:Hide()
			
		else
			
			LFRParentFrame:Show()
			end
	end
	LFRBrowseFrameRefreshButton:Hide()
end
---------------------
---------------------
---------------------
---------------------

raid_browser.gui = {}

local search_button = LFRQueueFrameFindGroupButton
local join_button = LFRBrowseFrameInviteButton
local refresh_button = LFRBrowseFrameRefreshButton

local name_column = LFRBrowseFrameColumnHeader1
local gs_list_column = LFRBrowseFrameColumnHeader2
local raid_list_column = LFRBrowseFrameColumnHeader3

gs_list_column:SetText('Илвл')
LFRBrowseFrameColumnHeader1:SetWidth(110)
LFRBrowseFrameColumnHeader2:SetWidth(45)
-- LFRBrowseFrameColumnHeader3:Hide()
LFRBrowseFrameColumnHeader3:SetWidth(78)
LFRBrowseFrameColumnHeader7:Hide()
raid_list_column:SetText('Рейд')
name_column:SetText('Кто собирает')

local function on_join()
	if LFRBrowseFrame.selectedName then
		local raid_name = raid_browser.lfm_messages[LFRBrowseFrame.selectedName].raid_info.name;
		local message = raid_browser.stats.build_inv_string(raid_name);
		SendChatMessage(message, 'WHISPER', nil, LFRBrowseFrame.selectedName);
	else
		print("RaidBrowserRU: Выберите рейд!")
	end	
end

local function clear_highlights()
	for i = 1, NUM_LFR_LIST_BUTTONS do
		_G["LFRBrowseFrameListButton"..i]:UnlockHighlight();
	end	
end

join_button:SetText('Авто сообщение')
join_button:SetScript('OnClick', on_join)


local function format_count(value)
   if value == 1 then
      return ' ';
   end
   
   return 's ' ;
end

local function format_seconds(seconds)
   local seconds = tonumber(seconds)
   
   if seconds <= 0 then
      return "00 seconds";
   end
   
   local days_text = '';
   local hours_text = '';
   local mins_text = '';
   local seconds_text = '';
   
   if seconds >= 86400 then
      local days = math.floor(seconds / 86400);
      days_text = days .. ' day' .. format_count(days);
      seconds = seconds % 86400;
   end
   
   if seconds >= 3600 then
      local hours = math.floor(seconds / 3600) ;
      hours_text = hours .. ' hr' .. format_count(hours);
      seconds = seconds % 3600;
   end
   
   if seconds >= 60 then 
      local minutes = math.floor(seconds / 60) ;
      minutes_text = minutes .. ' min' .. format_count(minutes);
   end
   
   return days_text .. hours_text .. minutes_text;
end

-- Setup tooltip and LFR button entry functionality.
for i = 1, NUM_LFR_LIST_BUTTONS do
	local button = _G["LFRBrowseFrameListButton"..i];
	button:SetScript("OnDoubleClick", on_join)
	button:SetScript("OnClick", 
		function(button) 
			LFRBrowseFrame.selectedName = button.unitName;
			clear_highlights();
			button:LockHighlight();
			LFRBrowse_UpdateButtonStates();
		end
	);
	
	button:SetScript('OnEnter', 
		function(button)
			GameTooltip:SetOwner(button, 'ANCHOR_RIGHT');
			
			local seconds = time() - button.lfm_info.time;
			local last_sent = string.format('Последнее сообщение: %d секунд назад', seconds);
			GameTooltip:AddLine(button.lfm_info.message, 1, 1, 1, true);
			GameTooltip:AddLine(last_sent);
			
			if button.raid_locked then
				GameTooltip:AddLine('\n|cffff0000Кд|cffffd100 для ' .. button.raid_info.name);
				
				-- local _, reset_time = raid_browser.stats.raid_lock_info(button.raid_info.instance_name, button.raid_info.size)
				-- GameTooltip:AddLine('Lockout expires in ' .. format_seconds(reset_time));
				local _, id = raid_browser.stats.raid_lock_info(button.raid_info.instance_name, button.raid_info.size, button.raid_info.difficulty)
				GameTooltip:AddLine('Id подземелья  ' .. tostring(id));
			else
				GameTooltip:AddLine('\n|cff00ffffНет кд|cffffd100 для ' .. button.raid_info.name);
			
			end
			
			GameTooltip:Show();
		end
	)
	
	button:SetScript('OnLeave', 
		function(self)
			GameTooltip:Hide();
		end
	)
end

-- Hide unused dropdown menu
LFRBrowseFrameRaidDropDown:Hide()

search_button:SetText('Find Raid')
search_button:SetScript('OnClick', function() end)

local function clear_highlights()
	for i = 1, NUM_LFR_LIST_BUTTONS do
		_G["LFRBrowseFrameListButton"..i]:UnlockHighlight();
	end	
end


-- Assignment operator for LFR buttons
local function assign_lfr_button(button, host_name, lfm_info, index,message)
		arg2 = arg2
		arg3 = arg3
	local offset = FauxScrollFrame_GetOffset(LFRBrowseFrameListScrollFrame);
	button.index = index;
	index = index - offset;

	button.lfm_info = lfm_info;
	button.raid_info = lfm_info.raid_info;
	
	
	-- Update selected LFR raid host name

	button.unitName = host_name;
	button.name:SetWidth(100);

	-- Update button text with raid host name , GS, Raid, and role information
--	if (arg3 == "орочий") then 
--	button.name:SetText('|cffff0000'..111);
--	else button.name:SetText(host_name);
--	end

	button.name:SetText(button.lfm_info.sender);
	button.level:SetText(button.lfm_info.gs); -- Previously level, now GS, then ilvl
	-----------------------------------------------------------------------------------------------------------------------------------
	-- button.level:Hide();
	button.level:SetWidth(30);

	-- Raid name
	button.class:SetText(button.raid_info.name); 

	button.raid_locked = raid_browser.stats.raid_lock_info(button.raid_info.instance_name, button.raid_info.size, button.raid_info.difficulty);
	button.type = "party";

	-- button.partyIcon:Show();
	button.partyIcon:Hide();

	button.tankIcon:Hide();
	button.healerIcon:Hide();
	button.damageIcon:Hide();
	
	-- Get all the roles from the lfm info table
	for _, role in pairs(button.lfm_info.roles) do 
		if role == 'tank' then
			button.tankIcon:Show()
		end

		if role == 'healer' then
			button.healerIcon:Show();
		end

		if role == 'melee_dps' or role == 'ranged_dps' or role == 'dps' then
			button.damageIcon:Show();
		end
	end
	
	button:Enable();
--	button.name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
--	button.level:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	-- -----------------------------------------------
	-- button.level:SetMax(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	-- If the raid is saved, then color the raid text in the list as red
	if button.raid_locked then
		button.class:SetTextColor(1, 0, 0);
	else
		button.class:SetTextColor(0, 1, 1);
	end;
	
	-- Set up the corresponding textures for the roles columns
	button.tankIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
	button.healerIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
	button.damageIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
	button.partyIcon:SetTexture("Interface\\LFGFrame\\LFGRole");
	button.partyIcon:Hide();
	LFRBrowseFrameRefreshButton:Hide();
end

local function insert_lfm_button(button, index)
	local host_name = nil;
	local count = 1;
	
	for n, lfm_info in pairs(raid_browser.lfm_messages) do
		if count == index then
			assign_lfr_button(button, n, lfm_info, index);
			break;
		end

		count = count + 1;
	end
	
end

local function update_buttons()
	local playerName = UnitName("player");
	local selectedName = LFRBrowseFrame.selectedName;
	
	if selectedName then
		LFRBrowseFrameSendMessageButton:Enable();
		LFRBrowseFrameInviteButton:Enable();
	else
		LFRBrowseFrameSendMessageButton:Disable();
		LFRBrowseFrameInviteButton:Disable();
	end
end

local function clear_list()
	for i = 1, NUM_LFR_LIST_BUTTONS do
		local button = _G["LFRBrowseFrameListButton"..i];
		button:Hide();
		button:UnlockHighlight();
	end
end

local function table_length(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function raid_browser.gui.update_list()
	LFRBrowseFrameRefreshButton.timeUntilNextRefresh = LFR_BROWSE_AUTO_REFRESH_TIME;
	  
	local numResults = table_length(raid_browser.lfm_messages)

	FauxScrollFrame_Update(LFRBrowseFrameListScrollFrame, numResults, NUM_LFR_LIST_BUTTONS, 16);

	local offset = FauxScrollFrame_GetOffset(LFRBrowseFrameListScrollFrame);

	clear_list();

	-- Update button information
	for i = 1, NUM_LFR_LIST_BUTTONS do
		local button = _G["LFRBrowseFrameListButton"..i];
		if ( i <= numResults ) then
			insert_lfm_button(button, i + offset);
			button:Show();
		else
			button:Hide();
		end
	end

	clear_highlights();

	-- Update button highlights
	for i = 1, NUM_LFR_LIST_BUTTONS do
		local button = _G["LFRBrowseFrameListButton"..i];
		if ( LFRBrowseFrame.selectedName == button.unitName ) then
			button:LockHighlight();
		else
			button:UnlockHighlight();
		end

		update_buttons();
	end
end

-- Setup LFR browser hooks
LFRBrowse_UpdateButtonStates = update_buttons
LFRBrowseFrameList_Update = raid_browser.gui.update_list
LFRBrowseFrameListButton_SetData = insert_lfm_button

-- Set the "Browse" tab to be active.
LFRFrame_SetActiveTab(2)

LFRParentFrameTab1:Hide();
LFRParentFrameTab2:Hide();