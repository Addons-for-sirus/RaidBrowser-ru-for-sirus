
-- Register addon
-- raid_browser = LibStub('AceAddon-3.0'):NewAddon('RaidBrowser', 'AceConsole-3.0')
local addonName, vars = ...
local L = vars.L
if AceLibrary:HasInstance("FuBarPlugin-2.0") then
	RaidBrowser = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceDB-2.0","AceEvent-2.0","FuBarPlugin-2.0")
else
	RaidBrowser = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceDB-2.0","AceEvent-2.0")
end

local TITLE = rbTitle
local addon = RaidBrowser
addon.vars = vars
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




local AceEvent = AceLibrary("AceEvent-2.0")
-- local RL = AceLibrary("Roster-2.1")
-- AceDB stuff
addon:RegisterDB("RaidBrowserDB")
addon:RegisterDefaults("profile", {


	})

-- ACE options menu
local options = {
	type = 'group',
	handler = RaidBrowser,
	args = {
	}
}


-- function lfrchange()
-- 	LFRFrame_SetActiveTab(2)

-- end
-- if not spaminfo then

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-----------------------------------------history locals
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

local function LogRecordToStringRB(record)
	-- if record <= #historyRB then return "---------" end
	-- local timestamp, name, message = unpack(record)
    local timestamp = record.timespam
	local name = record.namespam
	local raid = record.raid
    -- print(timestamp, name, message)
	if not timestamp or not name or not raid then
		return "NAIDI MENYA"
	else
   		return string.format("%s %s %s",date("%Y-%m-%d %H:%M", timestamp), name, raid)
	end
end
------------------
function GetLogRecordRB(i)
	-- print(86)
    local logsize = #historyRB
    assert(i >= 0 and i < #historyRB, "Index "..i.." is out of bounds")
    return LogRecordToStringRB(historyRB[logsize - i])
end

------------------
------------------
------------------
------------------
------------------
-- local function LogRecordToStringRBTooltip(record)
-- 	-- if record <= #historyRB then return "---------" end
-- 	-- local timestamp, name, message = unpack(record)
--     local timestamp = record.timespam
-- 	local name = record.namespam
-- 	local message = record.spammessage
--     -- print(timestamp, name, message)
-- 	if not timestamp or not name or not message then
-- 		return "NAIDI MENYA"
-- 	else
--    		return record.timespam,
-- 	end
-- end
-- ------------------
-- function GetLogRecordRBTooltip(i)
-- 	-- print(86)
--     local logsize = #historyRB
--     assert(i >= 0 and i < #historyRB, "Index "..i.." is out of bounds")
--     return LogRecordToStringRBTooltip(historyRB[logsize - i])
-- end
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
-----------------------------------------history locals
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------

-- end
local spamonoroff = false
-- local spamtime = 10
local lastspamtime = 0
local messagetospam
local messagetoshow


-- local messagetospam ="В "..intsname.." нужны "..tanks.. " танк(а)"..ddeal.." дд".. healers.." хила от "..ilvl.."%+ "..anrol

local function SendChatMessageOnUpd()
	-- if chattype == 4 then
	-- 	-- langid = ""
	-- elseif chattype == 5 then
	-- 	langid = ""
	-- end
	local nowtime = time()
	if spamonoroff and nowtime - spaminfo.rspamtime > lastspamtime then
		if spaminfo.langid == 1 then
			SendChatMessage(messagetospam, "CHANNEL", "орочий", spaminfo.chattospam)
			-- print(96)
		elseif spaminfo.langid == 2 then
			SendChatMessage(messagetospam, "CHANNEL", "всеобщий", spaminfo.chattospam)
			-- print(99)
		elseif spaminfo.langid == 3 then
			if  UnitDebuff("player",GetSpellInfo(309328)) then
				SendChatMessage(messagetospam,"CHANNEL", "орочий", spaminfo.chattospam)
			elseif UnitDebuff("player",GetSpellInfo(309327)) then
				SendChatMessage(messagetospam,"CHANNEL", "всеобщий", spaminfo.chattospam)
			end
		end

	spaminfo.rspamtime = math.random(spaminfo.spamtime-3,spaminfo.spamtime+7)
	lastspamtime = time()
	end
end

local function SendSpam()
	if #messagetospam > 255 then return end
	local f = CreateFrame("Frame",nil,UIParent)
	f:SetScript("OnUpdate",SendChatMessageOnUpd)
end

local function space(str, limit, indent, indent1)
	indent = indent or ""
	indent1 = indent1 or indent
	limit = limit or 70
	local here = 1-#indent1
	local function check(sp, st, word, fi)
	   if fi - here > limit then
		  here = st - #indent
		  return "\n"..indent..word
	   end
	end
	return indent1..str:gsub("(%s+)()(%S+)()", check)
 end

local function UpdateTextSpam()

	----------------create message
	local tankmes
	local ddmes
	local healmes
	local tanksebmes
	local ddealebmes
	local healersebmes
	-- local anrolmes
	----tankmes
	if spaminfo.tanks == 0 then
		tankmes = ""
	else
		tankmes = spaminfo.tanks.. " танк(а) "
	end

	if spaminfo.tankseb ~= "" then
		tanksebmes = "("..spaminfo.tankseb..") "
	else
		 tanksebmes = spaminfo.tankseb
	end
	----ddmes
	if spaminfo.ddeal == 0 then
		ddmes = ""
	else
		ddmes = spaminfo.ddeal.." дд "
	end

	if spaminfo.ddealeb ~= "" then
		ddealebmes = "("..spaminfo.ddealeb..") "
	else ddealebmes = spaminfo.ddealeb
	end
	---- healmes
	if spaminfo.healers == 0 then
		healmes = ""
	else
		healmes = spaminfo.healers.." хила/ов "
	end

	if spaminfo.healerseb ~= "" then
		healersebmes = "("..spaminfo.healerseb..") "
	else healersebmes = spaminfo.healerseb
	end

	if not _G["RBSpamString"] then
		local spmstr = CreateFrame("Frame","RBSpamString",LFRQueueFrame)
		spmstr:SetPoint("CENTER",LFRQueueFrame,"BOTTOM")
		local fntstr = spmstr:CreateFontString("AllMassage",OVERLAY,"GameTooltipText")
		fntstr:SetPoint("CENTER",LFRQueueFrame,"BOTTOM",0,30)
		local fntstrcount = spmstr:CreateFontString("AllMassageCount",OVERLAY,"GameTooltipText")
		fntstrcount:SetPoint("CENTER",LFRQueueFrame,"BOTTOM",0,60)
		spaminfo.intsname = spaminfo.intsname or "__"
		spaminfo.tanks = spaminfo.tanks or "__"
		spaminfo.ddeal = spaminfo.ddeal or "__"
		spaminfo.healers = spaminfo.healers or "__"
		spaminfo.ilvl = spaminfo.ilvl or "__"
		spaminfo.anrol = spaminfo.anrol or "__"
		spaminfo.tankseb = spaminfo.tankseb or "__"
		spaminfo.ddealeb = spaminfo.ddealeb or "__"
		spaminfo.healerseb = spaminfo.healerseb or "__"
		spaminfo.dopinfo = spaminfo.dopinfo or "__"

		---- create last mes
		messagetospam = spaminfo.intsname.." нужны " .. tankmes .. tanksebmes .. ddmes .. ddealebmes .. healmes .. healersebmes .." от ".. spaminfo.ilvl .."+ "..spaminfo.anrol .. " "..spaminfo.dopinfo
		fntstrcount:SetText(#messagetospam.."/255" or "__/255")
		-- if #messagetospam > 70 then
		-- 	messagetospam = "В "..spaminfo.intsname.." нужны " .. tankmes .. tanksebmes .. ddmes .. ddealebmes .."\n".. healmes .. healersebmes .." от ".. spaminfo.ilvl .."+ "..spaminfo.anrol .. " "..spaminfo.dopinfo
		-- end
		messagetoshow = space(messagetospam, 70," ", "  ")
		-- messagetospam =

		fntstr:SetText(messagetoshow)
	else
		if spaminfo.tanks == 0 and spaminfo.ddeal == 0 and spaminfo.healers == 0 then
			messagetospam = spaminfo.intsname.." нужны все от " .. spaminfo.ilvl.."+ "..spaminfo.anrol  .. " "..spaminfo.dopinfo
		else
			messagetospam = spaminfo.intsname.." нужны " .. tankmes .. tanksebmes .. ddmes .. ddealebmes .. healmes .. healersebmes .." от ".. spaminfo.ilvl .."+ "..spaminfo.anrol .. " "..spaminfo.dopinfo
			-- if #messagetospam > 70 then
			-- 	messagetospam = "В "..spaminfo.intsname.." нужны " .. tankmes .. tanksebmes .. ddmes .. ddealebmes .."\n".. healmes .. healersebmes .." от ".. spaminfo.ilvl .."+ "..spaminfo.anrol .. " "..spaminfo.dopinfo
			-- end
		end
		messagetoshow = space(messagetospam, 70," ", "  ")

		AllMassage:SetText(messagetoshow)
		-- messagetospam = space(messagetospam, 70," ", "  ")
		-- AllMassage:SetText(messagetospam)
		AllMassageCount:SetText(#messagetospam.."/255")
	end

end


local dungeonstoshow = {

	"М/Г об",
	"М/Г хм",
	"ИК/Оня 10",
	"ИК/Оня 25",
	"фул охота",
	"ИВК 10",
	"ИВК 25",
	"-------------",
	"на 3 рлк",
	"на 3 рбк",
	"-------------",
	"ОВ 10",
	"ОВ 25",
	"ОС 10",
	"ОС 25",
	"Накс 10",
	"Накс 25",
	"Сa 10",
	"Сa 25",
	"-------------",
	"Кара об",
	"Кара хм",
	"ЗА",
	"-------------",
	"Цлк 10 об",
	"Цлк 25 об",
	"Цлк 10 хм",
	"Цлк 25 хм",
	"РС 10 об",
	"РС 25 об",
	"РС 10 хм",
	"РС 25 хм",
	"-------------",
	"ЗС об",
	"ЗС хм",
	"Око об",
	"Око хм",
	"-------------",
	"Ульда 10 об",
	"Ульда 10 хм",
	"Ульда 25 об",
	"Ульда 25 хм",
	-- "-------------",
	-- "Зорт",

}

local function RaidsRBOnInit(dropdown)
	-- local parent = dropdown:GetParent()
	-- local dungeons = dungeonstoshow
		for i,n in pairs(dungeonstoshow) do
			-- if dungeons[i+2] == 2 then
			local info = UIDropDownMenu_CreateInfo()
			info.text = n
			if n ~= "-------------" then
				info.func = function(self)
					UIDropDownMenu_SetSelectedID(dropdown, i)
					-- parent.otherLabel:SetAlpha(0.25)
					-- parent.otherEditBox:SetAlpha(0.25)
					-- parent.otherEditBox:EnableKeyboard(false)
					-- parent.otherEditBox:EnableMouse(false)
					-- parent.otherEditBox:ClearFocus()
					spaminfo.intsname = UIDropDownMenu_GetText(dropdown)
					-- local last_award = EPGP.db.profile.last_awards[reason]
					-- if last_award then
					-- 	parent.editBox:SetText(last_award)
					-- end
					-- print(intsname)
					UpdateTextSpam()
				end
			end
			UIDropDownMenu_AddButton(info)
			-- end
		end
end


LFRParentFrame:HookScript("OnUpdate", function()
	LFRBrowseFrameInviteButton:SetWidth(113)
	LFRBrowseFrameInviteButton:ClearAllPoints()
	LFRBrowseFrameInviteButton:SetPoint("BOTTOMLEFT", 230, 12)
	for i = 1,4 do
		_G["LFRQueueFrameSpecificListButton"..i]:Hide()
	end
	LFRQueueFrameRoleButtonTank:Hide()
	LFRQueueFrameRoleButtonHealer:Hide()
	LFRQueueFrameRoleButtonDPS:Hide()
	LFRQueueFrameFindGroupButton:Hide()
	LFRQueueFrameAcceptCommentButton:Hide()
	LFRQueueFrameComment:Hide()
	LFRQueueFrameCommentTextButton:Hide()
	LFRBrowseFrameRefreshButton:Hide()
	LFRParentFrameTab1:SetText("Собрать")
	LFRQueueFrameSpecific:Hide()

end)

LFRParentFrame:HookScript("OnShow", function()
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------button for spam
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBStartSpamButton"] then
		local f = CreateFrame("Button","RBStartSpamButton",LFRQueueFrame,"StaticPopupButtonTemplate")
		f:SetSize(120,20)
		f:SetText("Старт")
		f:SetPoint("CENTER",LFRQueueFrame,"TOPRIGHT",-90,-90)
		f:Show()
		f:SetScript("OnClick",function()
			if spamonoroff then
				spamonoroff = false
				f:SetText("Старт")
			else
				spamonoroff = true
				f:SetText("Выкл")
			end
			SendSpam()
		end)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------raid pick
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBNumRaidsDropDown"] then
		local drpdwn = CreateFrame("Frame","RBNumRaidsDropDown",LFRQueueFrame,"UIDropDownMenuTemplate")
		drpdwn:EnableMouse(true)
		UIDropDownMenu_Initialize(drpdwn, RaidsRBOnInit)
		UIDropDownMenu_SetWidth(drpdwn, 120)
		UIDropDownMenu_SetText(drpdwn, spaminfo.intsname)
		drpdwn:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-100,-120)
		UpdateTextSpam()
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------tank slider
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBTankSlider"] then
		local tankslider = CreateFrame("Slider","RBTankSlider",LFRQueueFrame,"OptionsSliderTemplate")
		tankslider:SetWidth(100)
		tankslider:SetHeight(20)
		tankslider:SetOrientation('HORIZONTAL')
		tankslider:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-270,-90)
		tankslider:Show()

		tankslider:SetMinMaxValues(0, 5)
		tankslider:SetValueStep(1)
		tankslider:SetValue(spaminfo.tanks or 1)
		_G[tankslider:GetName()..'Low']:SetText('0')
		_G[tankslider:GetName()..'Low']:ClearAllPoints()
		_G[tankslider:GetName()..'Low']:SetPoint("LEFT",tankslider,"LEFT",0,1)

		_G[tankslider:GetName()..'High']:SetText('5')
		_G[tankslider:GetName()..'High']:ClearAllPoints()
		_G[tankslider:GetName()..'High']:SetPoint("RIGHT",tankslider,"RIGHT",0,1)

		_G[tankslider:GetName()..'Text']:SetText("Танки ("..spaminfo.tanks..")")
		tankslider:SetScript("OnValueChanged", function(self, newvalue)
			spaminfo.tanks = newvalue
			_G[tankslider:GetName()..'Text']:SetText("Танки ("..spaminfo.tanks..")")
			UpdateTextSpam()
		end)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------tank eb
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBTankEditBox"] then
		local tankseb = CreateFrame("EditBox", "RBTankEditBox", LFRQueueFrame, "InputBoxTemplate")
		tankseb:SetWidth(100)
		tankseb:SetHeight(20)
		tankseb:SetAutoFocus(false)
		tankseb:SetPoint("BOTTOM", RBTankSlider, "BOTTOM",0,-20)
		tankseb:SetText(spaminfo.tankseb or "")
		tankseb:SetScript("OnEnterPressed",function()
			spaminfo.tankseb = tankseb:GetText()
			tankseb:SetText(spaminfo.tankseb)
			tankseb:ClearFocus()
			-- print(tankeb:GetText())
			UpdateTextSpam()
		end)
		tankseb:Show()
		tankseb:SetScript("OnEnter",function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
			GameTooltip:AddLine("Сюда можно вписывать дополнительнную информация по танкам (отображается в скобках)")
			GameTooltip:AddLine("Пример: (не дк)")
			GameTooltip:Show()

		end)
		tankseb:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
		-- local tankfontstring = tankseb:CreateFontString("TankText",OVERLAY,"GameTooltipText")
		-- tankfontstring:SetText("Танки доп текст")
		-- tankfontstring:SetPoint("TOP",tankseb,"TOP",0,20)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------dd slider
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBDDSlider"] then
		local ddslider = CreateFrame("Slider","RBDDSlider",LFRQueueFrame,"OptionsSliderTemplate")
		ddslider:SetWidth(100)
		ddslider:SetHeight(20)
		ddslider:SetOrientation('HORIZONTAL')
		ddslider:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-270,-140)
		ddslider:Show()	
		ddslider:SetMinMaxValues(0, 20)
		ddslider:SetValueStep(1)
		ddslider:SetValue(spaminfo.ddeal or 1)
		_G[ddslider:GetName()..'Low']:SetText('0')
		_G[ddslider:GetName()..'Low']:ClearAllPoints()
		_G[ddslider:GetName()..'Low']:SetPoint("LEFT",ddslider,"LEFT",0,1)

		_G[ddslider:GetName()..'High']:SetText('20')
		_G[ddslider:GetName()..'High']:ClearAllPoints()
		_G[ddslider:GetName()..'High']:SetPoint("RIGHT",ddslider,"RIGHT",4,1)

		_G[ddslider:GetName()..'Text']:SetText("ДД ("..spaminfo.ddeal..")")
		ddslider:SetScript("OnValueChanged", function(self, newvalue)
			spaminfo.ddeal = newvalue
			_G[ddslider:GetName()..'Text']:SetText("ДД ("..spaminfo.ddeal..")")
			UpdateTextSpam()
		end)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------dd eb
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBDDEditBox"] then
		local ddealeb = CreateFrame("EditBox", "RBDDEditBox", LFRQueueFrame, "InputBoxTemplate")
		ddealeb:SetWidth(100)
		ddealeb:SetHeight(20)
		ddealeb:SetAutoFocus(false)
		ddealeb:SetPoint("BOTTOM", RBDDSlider, "BOTTOM",0,-20)
		ddealeb:SetText(spaminfo.ddealeb or "")
		ddealeb:SetScript("OnEnterPressed",function()
			spaminfo.ddealeb = ddealeb:GetText()
			ddealeb:SetText(spaminfo.ddealeb)
			ddealeb:ClearFocus()
			-- print(tankeb:GetText())
			UpdateTextSpam()
		end)
		ddealeb:Show()
		-- local ddealfontstring = ddealeb:CreateFontString("DDText",OVERLAY,"GameTooltipText")
		-- ddealfontstring:SetText("ДД доп текст")
		-- ddealfontstring:SetPoint("TOP",ddealeb,"TOP",0,20)
		ddealeb:SetScript("OnEnter",function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
			GameTooltip:AddLine("Сюда можно вписывать дополнительнную информация по дд (отображается в скобках)")
			GameTooltip:AddLine("Пример: 8 дд (не энх(энхи не дамажат))")
			GameTooltip:Show()
		end)
		ddealeb:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------heal slider
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBHealSlider"] then
		local healslider = CreateFrame("Slider","RBHealSlider",LFRQueueFrame,"OptionsSliderTemplate")
		healslider:SetWidth(100)
		healslider:SetHeight(20)
		healslider:SetOrientation('HORIZONTAL')
		healslider:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-270,-190)
		healslider:Show()
		
		healslider:SetMinMaxValues(0, 5)
		healslider:SetValueStep(1)
		healslider:SetValue(spaminfo.healers or 1)
		_G[healslider:GetName()..'Low']:SetText('0')
		_G[healslider:GetName()..'Low']:ClearAllPoints()
		_G[healslider:GetName()..'Low']:SetPoint("LEFT",healslider,"LEFT",0,1)

		_G[healslider:GetName()..'High']:SetText('5')
		_G[healslider:GetName()..'High']:ClearAllPoints()
		_G[healslider:GetName()..'High']:SetPoint("RIGHT",healslider,"RIGHT",0,1)
		_G[healslider:GetName()..'Text']:SetText("Хилы ("..spaminfo.healers..")")
		healslider:SetScript("OnValueChanged", function(self, newvalue)
			spaminfo.healers = newvalue
			_G[healslider:GetName()..'Text']:SetText("Хилы ("..spaminfo.healers..")")
			UpdateTextSpam()
		end)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------heal eb
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBHealEditBox"] then
		local healerseb = CreateFrame("EditBox", "RBHealEditBox", LFRQueueFrame, "InputBoxTemplate")
		healerseb:SetWidth(100)
		healerseb:SetHeight(20)
		healerseb:SetAutoFocus(false)
		healerseb:SetPoint("BOTTOM", RBHealSlider, "BOTTOM",0,-20)
		healerseb:SetText(spaminfo.healerseb or "")
		healerseb:SetScript("OnEnterPressed",function()
			spaminfo.healerseb = healerseb:GetText()
			healerseb:SetText(spaminfo.healerseb)
			healerseb:ClearFocus()
			-- print(tankeb:GetText())
			UpdateTextSpam()
		end)
		healerseb:Show()
		-- local healfontstring = healerseb:CreateFontString("HealText",OVERLAY,"GameTooltipText")
		-- healfontstring:SetText("Хилы доп текст")
		-- healfontstring:SetPoint("TOP",healerseb,"TOP",0,20)
		healerseb:SetScript("OnEnter",function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
			GameTooltip:AddLine("Сюда можно вписывать дополнительнную информация по хилам (отображается в скобках)")
			GameTooltip:AddLine("Пример: 2 хила (дц фул)")
			GameTooltip:Show()
		end)
		healerseb:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------ilvl slider
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not  _G["RBILVLSlider"] then
		local ilvlslider = CreateFrame("Slider","RBILVLSlider",LFRQueueFrame,"OptionsSliderTemplate")
		ilvlslider:SetWidth(100)
		ilvlslider:SetHeight(20)
		ilvlslider:SetOrientation('HORIZONTAL')
		ilvlslider:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-270,-260)
		ilvlslider:SetMinMaxValues(200, 300)
		ilvlslider:SetValueStep(5)
		ilvlslider:SetValue(spaminfo.ilvl or 200)
		_G[ilvlslider:GetName()..'Low']:SetText('200')
		_G[ilvlslider:GetName()..'Low']:ClearAllPoints()
		_G[ilvlslider:GetName()..'Low']:SetPoint("LEFT",ilvlslider,"LEFT",-15,1)

		_G[ilvlslider:GetName()..'High']:SetText('290')
		_G[ilvlslider:GetName()..'High']:ClearAllPoints()
		_G[ilvlslider:GetName()..'High']:SetPoint("RIGHT",ilvlslider,"RIGHT",15,1)

		_G[ilvlslider:GetName()..'Text']:SetText("ilvl ("..spaminfo.ilvl.."+)")
		ilvlslider:SetScript("OnValueChanged", function(self, newvalue)
			spaminfo.ilvl = newvalue
			_G[ilvlslider:GetName()..'Text']:SetText("ilvl ("..spaminfo.ilvl.."+)")
			UpdateTextSpam()
		end)
		-- ilvlslider:Show()
	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------anrol eb
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not  _G["RBAnrolText"] then
		local anrol = CreateFrame("EditBox", "RBAnrolText", LFRQueueFrame, "InputBoxTemplate")
		anrol:SetWidth(100)
		anrol:SetHeight(20)
		anrol:SetAutoFocus(false)
		anrol:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-270,-300)
		anrol:SetText(spaminfo.anrol or "")
		anrol:SetScript("OnEnterPressed",function()
			spaminfo.anrol = anrol:GetText()
			anrol:SetText(spaminfo.anrol)
			anrol:ClearFocus()
			-- print(anrol:GetText())
			UpdateTextSpam()
		end)
		anrol:Show()
		local anrolfontstring = anrol:CreateFontString("AnrolText",OVERLAY,"GameTooltipText")
		anrolfontstring:SetText("Анролы")
		anrolfontstring:SetPoint("TOP",anrol,"TOP",0,15)
		anrol:SetScript("OnEnter",function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
			GameTooltip:AddLine("Сюда можно вписывать дополнительнную информация по анролам")
			GameTooltip:AddLine("Пример: 1 анрол или бое анрол или групп лут и т.д")
			GameTooltip:Show()
		end)
		anrol:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
	end

	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------dop infa eb
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not _G["RBDInfoText"] then
		local dopinfo = CreateFrame("EditBox", "RBDInfoText", LFRQueueFrame, "InputBoxTemplate")
		dopinfo:SetWidth(100)
		dopinfo:SetHeight(20)
		dopinfo:SetAutoFocus(false)
		dopinfo:SetPoint("CENTER", LFRQueueFrame, "TOPRIGHT",-270,-340)
		dopinfo:SetText(spaminfo.dopinfo or "")
		dopinfo:SetScript("OnEnterPressed",function()
			spaminfo.dopinfo = dopinfo:GetText()
			dopinfo:SetText(spaminfo.dopinfo)
			dopinfo:ClearFocus()
			-- print(anrol:GetText())
			UpdateTextSpam()
		end)
		dopinfo:Show()
		local dopinfofontstring = dopinfo:CreateFontString("DopInfoText",OVERLAY,"GameTooltipText")
		dopinfofontstring:SetText("Доп инфо")
		dopinfofontstring:SetPoint("TOP",dopinfo,"TOP",0,15)
		dopinfo:SetScript("OnEnter",function(self)
			GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
			GameTooltip:AddLine("Сюда можно вписывать простую дополнительнную информация, пишется в конце")
			GameTooltip:AddLine("Пример: 2 босса убиты, с тухлого, без алара")
			GameTooltip:Show()
		end)
		dopinfo:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
	end

	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------checkboxes spam lang
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	for i = 1,10 do
		local id, name = GetChannelName(i);
		if name == "Поиск спутников(А)" then
			spaminfo.alliancechat = true
			spaminfo.alliancechatid = id
		elseif name == "Поиск спутников(О)" then
			spaminfo.hordechat = true
			spaminfo.hordechatid = id
		elseif name == "Поиск спутников" then
			spaminfo.lfgchat = true
			spaminfo.lfgchatid = id
		end
	end

	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------channel fntstrng
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------

	local channelfontstring = LFRQueueFrame:CreateFontString("RBChannelText",OVERLAY,"GameTooltipText")
	channelfontstring:SetText("Каналы")
	channelfontstring:SetPoint("RIGHT",RBDInfoText,"RIGHT", 70, 180)

	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------checkboxes spam lang all
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if spaminfo.alliancechatid ~= nil and not _G["RBCheckButton"..spaminfo.alliancechatid] and spaminfo.alliancechat  then
		local chkbx1 = CreateFrame("CheckButton","RBCheckButton"..spaminfo.alliancechatid,LFRQueueFrame,"UICheckButtonTemplate")
		chkbx1:SetPoint("CENTER", RBDInfoText, "CENTER", 150, 180)
		chkbx1:SetSize(25,25)
		
		chkbx1:SetScript("OnClick",function()
			-- print(chkbx1:GetChecked())
			if chkbx1:GetChecked() == 1 then
				spaminfo.chattospam = spaminfo.alliancechatid
				spaminfo.langid = 2
				_G["RBCheckButton"..spaminfo.hordechatid]:SetChecked(false)
			else
				_G["RBCheckButton"..spaminfo.hordechatid]:SetChecked(true)
				spaminfo.langid = 1
				spaminfo.chattospam = spaminfo.hordechatid
			end
		end)
		local chkbx1fontstring = chkbx1:CreateFontString("RBCheckButton"..spaminfo.alliancechatid.."Text",OVERLAY,"GameTooltipText")
		chkbx1fontstring:SetText(spaminfo.alliancechatid)
		chkbx1fontstring:SetPoint("TOP",chkbx1,"TOP",0,10)
	end

	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------checkboxes spam lang horde
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if  spaminfo.hordechatid  ~= nil and  not  _G["RBCheckButton"..spaminfo.hordechatid] and spaminfo.hordechat then
		local chkbx2 = CreateFrame("CheckButton","RBCheckButton"..spaminfo.hordechatid,LFRQueueFrame,"UICheckButtonTemplate")
		chkbx2:SetPoint("CENTER", RBDInfoText, "CENTER", 200, 180)
		chkbx2:SetSize(25,25)
		chkbx2:SetScript("OnClick",function()
			if chkbx2:GetChecked() == 1 then
				spaminfo.chattospam = spaminfo.hordechatid
				_G["RBCheckButton"..spaminfo.alliancechatid]:SetChecked(false)
				spaminfo.langid = 1
			else
				_G["RBCheckButton"..spaminfo.alliancechatid]:SetChecked(true)
				spaminfo.chattospam = spaminfo.alliancechatid
				spaminfo.langid = 2
			end
		end)
		local chkbx2fontstring = chkbx2:CreateFontString("RBCheckButton"..spaminfo.hordechatid.."Text",OVERLAY,"GameTooltipText")
		chkbx2fontstring:SetText(spaminfo.hordechatid)
		chkbx2fontstring:SetPoint("TOP",chkbx2,"TOP",0,10)
	end

	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------checkboxes spam lang lfg
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not  _G["RBCheckButton"..spaminfo.lfgchatid] and not (spaminfo.hordechat or spaminfo.alliancechat) then
		local chkbx3 = CreateFrame("CheckButton","RBCheckButton"..spaminfo.lfgchatid,LFRQueueFrame,"UICheckButtonTemplate")
		chkbx3:SetPoint("CENTER", RBDInfoText, "CENTER", 150, 180)
		chkbx3:SetSize(25,25)
		chkbx3:SetScript("OnClick",function()
			if chkbx3:GetChecked() == 1 then
				spaminfo.chattospam = spaminfo.lfgchatid
				spaminfo.langid = 3
				-- RBCheckButton1:SetChecked(false)
			else
				spaminfo.chattospam = spaminfo.lfgchatid
				spaminfo.langid = 3
				-- spaminfo.chattospam = false
			end
		end)
		local chkbx3fontstring = chkbx3:CreateFontString("RBCheckButton"..spaminfo.lfgchatid.."Text",OVERLAY,"GameTooltipText")
		chkbx3fontstring:SetText(spaminfo.lfgchatid)
		chkbx3fontstring:SetPoint("TOP",chkbx3,"TOP",0,10)

	end
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	--------------------------------------------------
	--------------------------------------------------spamtime slider
	--------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------
	if not  _G["RBSpamTimerSlider"]  then
		local spmtimeslider = CreateFrame("Slider","RBSpamTimerSlider",LFRQueueFrame,"OptionsSliderTemplate")
		spmtimeslider:SetWidth(100)
		spmtimeslider:SetHeight(20)
		spmtimeslider:SetOrientation('HORIZONTAL')
		spmtimeslider:SetPoint("RIGHT",RBDInfoText,"RIGHT", 150, 130)

		spmtimeslider:SetMinMaxValues(40, 120)
		spmtimeslider:SetValueStep(1)
		spmtimeslider:SetValue(spaminfo.spamtime or 40)
		_G[spmtimeslider:GetName()..'Low']:SetText('40')
		_G[spmtimeslider:GetName()..'Low']:ClearAllPoints()
		_G[spmtimeslider:GetName()..'Low']:SetPoint("LEFT",spmtimeslider,"LEFT",-15,1)

		_G[spmtimeslider:GetName()..'High']:SetText('120')
		_G[spmtimeslider:GetName()..'High']:ClearAllPoints()
		_G[spmtimeslider:GetName()..'High']:SetPoint("RIGHT",spmtimeslider,"RIGHT",15,1)
		if spaminfo.spamtime then
			_G[spmtimeslider:GetName()..'Text']:SetText("Время отправки - ("..spaminfo.spamtime..")")
		else
			_G[spmtimeslider:GetName()..'Text']:SetText("Время отправки - (выберите время)")
		end
		spmtimeslider:SetScript("OnValueChanged", function(self, newvalue)
			spaminfo.spamtime = newvalue
			spaminfo.rspamtime = math.random(spaminfo.spamtime-3,spaminfo.spamtime+7)
			_G[spmtimeslider:GetName()..'Text']:SetText("Время отправки - ("..spaminfo.spamtime..")")
			UpdateTextSpam()
		end)
		spmtimeslider:Show()
	end
	---------------clear all
	if not  _G["RBClearAllButton"]  then
		local clearallbutton = CreateFrame("Button","RBClearAllButton",LFRQueueFrame,"StaticPopupButtonTemplate")

		clearallbutton:SetSize(120,20)
		clearallbutton:SetText("Очистить все")
		clearallbutton:SetPoint("CENTER",LFRQueueFrame,"TOPRIGHT",-90,-340)
		clearallbutton:Show()
		clearallbutton:SetScript("OnClick",function()
			spaminfo.intsname = ""
			spaminfo.tanks = 1
			spaminfo.tankseb = ""
			spaminfo.ddeal = 1
			spaminfo.ddealeb = ""
			spaminfo.healers = 1
			spaminfo.healerseb = ""
			spaminfo.ilvl = 200
			spaminfo.anrol = ""
			spaminfo.dopinfo = ""
			RBTankEditBox:SetText(spaminfo.tankseb)
			RBDDEditBox:SetText(spaminfo.ddealeb)
			RBHealEditBox:SetText(spaminfo.healerseb)
			RBAnrolText:SetText(spaminfo.anrol)
			RBDInfoText:SetText(spaminfo.dopinfo)
			UpdateTextSpam()
		end)
	end


end)



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--------------------------------------------------
--------------------------------------------------history frame
--------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------


local function SetCheckedButtons(index)
	for i = 1,5 do
		local button = _G["LFRHistoryFrameCheckButton"..i]
		if index == button.days then
			if index == 0 then
				spaminfo.historyenable = false
			else
				spaminfo.historyenable = true
			end
		button:SetChecked(true)
		end
	end
	-- print(spaminfo.historyenable)
end


function addon:UpdateHistory()
	local currenttime = time()
	local tableindex = 1
	while historyRB[tableindex] and historyRB[tableindex].timespam do
		if(currenttime - historyRB[tableindex].timespam > 60*60*24*(spaminfo.historytime or 1)) then
			table.remove(historyRB,tableindex)
		else
			tableindex = tableindex + 1
		end
	end
end

local function CreateLogFrame()
	if not _G["LFRHistoryFrame"] then
		local lfrhf = CreateFrame("Frame","LFRHistoryFrame",LFRParentFrame)
		lfrhf:SetAllPoints(LFRParentFrame)
		-- lfrhf:SetSize(355,440)
		lfrhf:Hide()
	end

	if not _G["LFRParentFrameTab3"] then
		local lfrtab3 = CreateFrame("Button","LFRParentFrameTab3",LFRParentFrame,"CharacterFrameTabButtonTemplate")

		lfrtab3:SetText(L["History"])
		-- lfrtab3:SetSize(97,32)
		lfrtab3:SetWidth(97)
		lfrtab3:SetPoint("LEFT", LFRParentFrameTab2, "RIGHT", -15, 0)
		PanelTemplates_SetNumTabs(LFRParentFrame,3)
		lfrtab3:SetScript("OnClick",function()
			LFRFrame_SetActiveTab(3)
		end)
		hooksecurefunc("LFRFrame_OnLoad",function(self)
			PanelTemplates_SetNumTabs(self, 3);
		end)
		hooksecurefunc("LFRFrame_SetActiveTab",function(tab)
			-- print("sadgsf")
			if ( tab == 1 ) then
				LFRParentFrame.activeTab = 1;
				LFRQueueFrame:Show();
				LFRBrowseFrame:Hide();
				LFRHistoryFrame:Hide();
				-- print(1)
			elseif ( tab == 2 ) then
				LFRParentFrame.activeTab = 2;
				LFRBrowseFrame:Show();
				LFRQueueFrame:Hide();
				LFRHistoryFrame:Hide();
				-- print(2)
			elseif ( tab == 3 ) then
				LFRParentFrame.activeTab = 3;
				LFRBrowseFrame:Hide();
				LFRQueueFrame:Hide();
				LFRHistoryFrame:Show();
			end
			PanelTemplates_SetTab(LFRParentFrame, tab);
		end)
	end

	for i = 1,5 do
		if not _G["LFRHistoryFrameCheckButton"..i] then
			local chbtn = CreateFrame("CheckButton", "LFRHistoryFrameCheckButton"..i,LFRHistoryFrame,"UICheckButtonTemplate")
			chbtn:SetSize(25,25)
			chbtn.index = i
			if i == 1 then
				chbtn:SetPoint("CENTER", LFRHistoryFrame, "TOP", -100, -50)
			else
				chbtn:SetPoint("RIGHT", _G["LFRHistoryFrameCheckButton"..i-1], "RIGHT", 50, 0)
			end
			-- chbtn:SetSize(25,25)
			local chkbxFontString = chbtn:CreateFontString("LFRHistoryFrameCheckButton"..i.."Text",OVERLAY,"GameTooltipText")
			chkbxFontString:SetPoint("TOP",chbtn,"TOP",0,10)
			if i == 1 then
				chkbxFontString:SetText("Выкл")
				chbtn.days = 0
			elseif i == 2 then
				chkbxFontString:SetText("1 день")
				chbtn.days = 1
			elseif i == 3 then
				chkbxFontString:SetText("3 дня")
				chbtn.days = 3
			elseif i == 4 then
				chkbxFontString:SetText("5 дней")
				chbtn.days = 5
			elseif i == 5 then
				chkbxFontString:SetText("7 дней")
				chbtn.days = 7
			end
		end
	end
	for i = 1,5 do
		if i == 1 then
			_G["LFRHistoryFrameCheckButton"..i]:SetScript("OnClick",function(self)
				-- local check = _G["LFRHistoryFrameCheckButton"..i]:GetChecked()
				for k = 1,5 do
					if k ~= _G["LFRHistoryFrameCheckButton"..i].index then
					_G["LFRHistoryFrameCheckButton"..k]:SetChecked(false)
					end
				end
				spaminfo.historytime = 0
				spaminfo.historyenable = false
				self:SetChecked(true)

			end)
		elseif i == 2 then
			_G["LFRHistoryFrameCheckButton"..i]:SetScript("OnClick",function(self)
				for k = 1,5 do
					if k ~= _G["LFRHistoryFrameCheckButton"..i].index then
					_G["LFRHistoryFrameCheckButton"..k]:SetChecked(false)
					end
				end
				spaminfo.historytime = 1
				spaminfo.historyenable = true
				self:SetChecked(true)
			end)
		elseif i == 3 then
			_G["LFRHistoryFrameCheckButton"..i]:SetScript("OnClick",function(self)
				for k = 1,5 do
					if k ~= _G["LFRHistoryFrameCheckButton"..i].index then
					_G["LFRHistoryFrameCheckButton"..k]:SetChecked(false)
					end
				end
				spaminfo.historytime = 3
				spaminfo.historyenable = true
				self:SetChecked(true)
			end)
		elseif i == 4 then
			_G["LFRHistoryFrameCheckButton"..i]:SetScript("OnClick",function(self)
				for k = 1,5 do
					if k ~= _G["LFRHistoryFrameCheckButton"..i].index then
					_G["LFRHistoryFrameCheckButton"..k]:SetChecked(false)
					end
				end
				spaminfo.historytime = 5
				spaminfo.historyenable = true
				self:SetChecked(true)
			end)
		elseif i == 5 then
			_G["LFRHistoryFrameCheckButton"..i]:SetScript("OnClick",function(self)
				for k = 1,5 do
					if k ~= _G["LFRHistoryFrameCheckButton"..i].index then
					_G["LFRHistoryFrameCheckButton"..k]:SetChecked(false)
					end
				end
				spaminfo.historytime = 7
				spaminfo.historyenable = true
				self:SetChecked(true)
			end)
		end
	end


	if not _G["LFRHistoryFrameScrollParent"] then
		local scrollParent = CreateFrame("Frame", "LFRHistoryFrameScrollParent",LFRHistoryFrame)
		scrollParent:SetPoint("CENTER",LFRHistoryFrame,"CENTER", 0, -30)
		scrollParent:SetSize(330,350)
		local font = "ChatFontSmall"
		local fontHeight = select(2, getglobal(font):GetFont())
		local recordHeight = fontHeight + 2
		local recordWidth = scrollParent:GetWidth() - 35
		local numLogRecordFrames = math.floor(
		(scrollParent:GetHeight() - 3) / recordHeight)
		-- local record = scrollParent:CreateFontString("LFRHistoryFrameRecordFrame1", OVERLAY, font)
		local record = CreateFrame("Button","LFRHistoryFrameRecordFrame1",LFRHistoryFrameScrollParent)
		record:SetHeight(recordHeight)
		record:SetWidth(recordWidth)
		local fnstng = record:CreateFontString("LFRHistoryFrameRecordFrameFS1",OVERLAY,"GameTooltipText")
		fnstng:SetPoint("LEFT",record,"LEFT",0,0)
		-- record:SetText("test")
		-- record:SetNonSpaceWrap(false)
		record:SetScript("OnEnter",function(self)
		end)
		record:SetScript("OnLeave",function(self)
			GameTooltip:Hide()
		end)
		record:SetPoint("TOPLEFT", scrollParent, "TOPLEFT", 5, -3)
		for i=2,numLogRecordFrames do
			record = CreateFrame("Button","LFRHistoryFrameRecordFrame"..i,LFRHistoryFrameScrollParent)
			record:SetHeight(recordHeight)
			record:SetWidth(recordWidth)
			fnstng = record:CreateFontString("LFRHistoryFrameRecordFrameFS"..i,OVERLAY,"GameTooltipText")
			fnstng:SetPoint("LEFT",record,"LEFT",0,0)
			record:SetScript("OnEnter",function(self)
			end)
			record:SetScript("OnLeave",function(self)
				GameTooltip:Hide()
			end)
			-- record:SetNonSpaceWrap(false)
			record:SetPoint("TOPLEFT", "LFRHistoryFrameRecordFrame"..(i-1), "BOTTOMLEFT")
		end

		local scrollBar = CreateFrame("ScrollFrame", "LFRHistoryFrameScrollFrame",scrollParent,"FauxScrollFrameTemplateLight")
		scrollBar:SetWidth(scrollParent:GetWidth() - 35)
		scrollBar:SetHeight(scrollParent:GetHeight() - 10)
		scrollBar:SetPoint("TOPRIGHT", scrollParent, "TOPRIGHT", -20, -10)

		function addon:LogChangedRB()
			if not LFRHistoryFrame:IsVisible() then
				return
			end
			--local log = #HistoryRB
			local offset = FauxScrollFrame_GetOffset(scrollBar)
			-- print(offset,862)
			local numRecords = #historyRB
			-- print(numRecords)
			local numDisplayedRecords = math.min(numLogRecordFrames, numRecords - offset)
			recordWidth = scrollParent:GetWidth() - 35
			for i=1,numLogRecordFrames do
				-- print(i,864)
				local buttontoshow = _G["LFRHistoryFrameRecordFrame"..i]
				local fnstrngtoshow = _G["LFRHistoryFrameRecordFrameFS"..i]
				buttontoshow:SetWidth(recordWidth)
				local logIndex = i + offset - 1
				-- print(logIndex,870)
				-- print(LogRecordToStringRB(logIndex),868)
				if logIndex < numRecords then
					-- print(874)
					-- recordtoshow:SetText
					-- print(LogRecordToStringRB(logIndex),870)
					fnstrngtoshow:SetText(GetLogRecordRB(logIndex))
					-- recordtoshow:SetPoint("LEFT",recordtoshow,"RIGHT")
					buttontoshow:SetScript("OnEnter",function(self)
						local tume,sender,raid,message
						tume = historyRB[#historyRB-logIndex].timespam
						sender = historyRB[#historyRB-logIndex].namespam
						raid = historyRB[#historyRB-logIndex].raid
						message = historyRB[#historyRB-logIndex].spammessage
						GameTooltip:SetOwner(self, 'ANCHOR_RIGHT');
						GameTooltip:AddLine("Время: "..date("%Y-%m-%d %H:%M", tume))
						GameTooltip:AddLine("Отправитель: "..sender)
						GameTooltip:AddLine("Подземелье: "..raid)
						GameTooltip:AddLine("Сообщение: \n"..message)
						GameTooltip:Show()
					end)
					buttontoshow:SetScript("OnLeave",function(self)
						GameTooltip:Hide()
					end)
					-- recordtoshow:SetJustifyH("LEFT")
					buttontoshow:Show()
				else
					buttontoshow:Hide()
				end
			end
			FauxScrollFrame_Update(scrollBar, numRecords, numDisplayedRecords, recordHeight)
		end
		LFRHistoryFrame:SetScript("OnUpdate",function()
			addon:UpdateHistory()
			addon:LogChangedRB()
		end)
		scrollBar:SetScript("OnVerticalScroll",function(self, value)
			FauxScrollFrame_OnVerticalScroll(scrollBar, value, recordHeight, addon.LogChangedRB)
		end)
	end
end






----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--------------------------------------------------
--------------------------------------------------history frame end
--------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------




function RaidBrowser:OnClick()
	-- LFRFrame_SetActiveTab(2)
	if LFRParentFrame:IsShown()   then
		HideUIPanel(LFRParentFrame)
	else
		ShowUIPanel(LFRParentFrame)
		-- LFRBrowseFrame:Show();
		-- LFRQueueFrame:Hide();
	end
end

addon.OnMenuRequest = options
function addon:OnInitialize()
	self:RegisterChatCommand("/rbru", "/RaidBrowserRU", options)
	spaminfo = spaminfo or {}
	spaminfo.intsname = spaminfo.intsname or ""
	spaminfo.tanks = spaminfo.tanks or 1
	spaminfo.tankseb = spaminfo.tankseb or ""
	spaminfo.ddeal = spaminfo.ddeal or 1
	spaminfo.ddealeb = spaminfo.ddealeb or ""
	spaminfo.healers = spaminfo.healers or 1
	spaminfo.healerseb = spaminfo.healerseb or ""
	spaminfo.ilvl = spaminfo.ilvl or 200
	spaminfo.chattospam = spaminfo.chattospam or ""
	spaminfo.langid = spaminfo.langid or ""
	spaminfo.anrol = spaminfo.anrol or ""
	spaminfo.dopinfo = spaminfo.dopinfo or ""
	spaminfo.alliancechat = spaminfo.alliancechat or false
	spaminfo.hordechat = spaminfo.hordechat or false
	spaminfo.lfgchat = spaminfo.lfgchat or false
	spaminfo.alliancechatid = spaminfo.alliancechatid or ""
	spaminfo.hordechatid = spaminfo.hordechatid or ""
	spaminfo.lfgchatid = spaminfo.lfgchatid or ""
	spaminfo.spamtime = spaminfo.spamtime or 35
	spaminfo.rspamtime = spaminfo.rspamtime or 35
	spaminfo.historyenable = spaminfo.historyenable or false
	spaminfo.historytime = spaminfo.historytime or 0
	CreateLogFrame()
	LFRParentFrame:HookScript("OnUpdate", function()
		LFRParentFrameTab1:SetWidth(90)
		LFRParentFrameTab2:SetWidth(90)
		LFRParentFrameTab3:SetWidth(90)
	end)
	SetCheckedButtons(spaminfo.historytime)
end

local LDB

function addon:OnEnable()

	self:OnProfileEnable()
	if LDB then
  	  return
	end
	if AceLibrary:HasInstance("LibDataBroker-1.1") then
		LDB = AceLibrary("LibDataBroker-1.1")
	elseif LibStub then
		LDB = LibStub:GetLibrary("LibDataBroker-1.1",true)
	end
	if LDB then
		local dataobj = LDB:GetDataObjectByName("RaidBrowser") or
		LDB:NewDataObject("RaidBrowser", {
		type = "launcher",
		label = "RaidBrowser",
		icon = "Interface\\AddOns\\RaidBrowser\\icon",
		})
		dataobj.OnClick = function(self, button)
			if button == "RightButton" then
				RaidBrowser:OpenMenu(self,addon)
				-- print("Clickr")
			else
				-- print("Clickl")
				RaidBrowser:OnClick()
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
	DEFAULT_CHAT_FRAME:HookScript("OnHyperlinkEnter", function(self, linkData, olink)
		if string.match(linkData,"^player::RaidBrowser:") then
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
			GameTooltip:SetText(L["Click to add this event to chat"])
			GameTooltip:Show()
		end
	end)
	DEFAULT_CHAT_FRAME:HookScript("OnHyperlinkLeave", function(self, linkData, link)
		if string.match(linkData,"^player::RaidBrowser:") then
			GameTooltip:Hide()
		end
	end)
end

function addon:OnProfileDisable()
    end

function addon:OnProfileEnable()
    end

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------- movable
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

LFRParentFrame:EnableMouse(true)
LFRParentFrame:SetMovable(true)
LFRParentFrame:RegisterForDrag("LeftButton")
--LFRParentFrame:Show()

LFRParentFrame:SetScript("OnDragStart", function(this)
  this:StartMoving()
  end)
LFRParentFrame:SetScript("OnDragStop", function(this)
  this:StopMovingOrSizing()
  local frame_x,frame_y = this:GetCenter()
  frame_x = frame_x - GetScreenWidth() / 2
  frame_y = frame_y - GetScreenHeight() / 2
  this:ClearAllPoints()
  this:SetPoint("CENTER", UIParent,"CENTER",frame_x,frame_y)
--   LFRBrowseFrameInviteButton:SetPoint("RIGHT", LFRParentFrame,"BOTTOM",165,22)
   -- UIParent:SetPoint("CENTER",LFRBrowseFrame,"CENTER",frame_x,frame_y)
--   LFRParentFrame:SetAllPoints(LFRBrowseFrame)
  end)
-- LFRParentFrame:SetScript("OnShow", function(this)
-- 	this:SetPoint("CENTER", UIParent,"CENTER",frame_x,frame_y)
-- end)
 LFRBrowseFrame:SetScript("OnShow", function(tralala)
	--LFRParentFrame:SetPoint("CENTER", LFRBrowseFrame,"CENTER",0,0)
		tralala:ClearAllPoints()
		tralala:SetAllPoints(LFRParentFrame)
		-- LFRBrowseFrameInviteButton:ClearAllPoints()
		-- LFRBrowseFrameInviteButton:SetPoint("RIGHT", LFRParentFrame,"BOTTOM",165,22)

	 end)

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------- movable
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

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
		print("RaidBrowser: Выберите рейд!")
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
				GameTooltip:AddLine('\n|cffff0000Кд для ' .. button.raid_info.name);

				-- local _, reset_time = raid_browser.stats.raid_lock_info(button.raid_info.instance_name, button.raid_info.size)
				-- GameTooltip:AddLine('Lockout expires in ' .. format_seconds(reset_time));
				local _, id = raid_browser.stats.raid_lock_info(button.raid_info.instance_name, button.raid_info.size, button.raid_info.difficulty,button.raid_info.locked)
				GameTooltip:AddLine('Id подземелья  ' .. tostring(id));
			else
				GameTooltip:AddLine('\n|cff00ff00Нет кд для ' .. button.raid_info.name);

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

-- local function clear_highlights()
-- 	for i = 1, NUM_LFR_LIST_BUTTONS do
-- 		_G["LFRBrowseFrameListButton"..i]:UnlockHighlight();
-- 	end
-- end


-- Assignment operator for LFR buttons
local function assign_lfr_button(button, host_name, lfm_info, index, message)
		-- arg2 = arg2
		-- arg3 = arg3
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

	button.raid_locked = raid_browser.stats.raid_lock_info(button.raid_info.instance_name, button.raid_info.size, button.raid_info.difficulty,button.raid_info.locked);
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
		button.class:SetTextColor(0, 255, 0);
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
-- LFRFrame_SetActiveTab(2)

-- LFRParentFrameTab1:Hide();
-- LFRParentFrameTab2:Hide();
