local _, _addon = ...

local xpText = QuestLogDetailScrollChildFrame:CreateFontString("QXPIText", "BACKGROUND", "QuestFont")
xpText:SetTextColor(0.15,0.15,0.15,1)
xpText:SetFont("Fonts\\FRIZQT__.TTF", 11)

--- Append xp display after money reward if it's there
-- @return true if successful, false if not
local function AddAfterMoney()
	if not QuestLogMoneyFrame:IsShown() then 
		return false;
	end
	xpText:SetPoint("LEFT", QuestLogMoneyFrame, "RIGHT", 5, 0);
	return true;
end

--- Append directly behind recieve text if it's there
-- @return true if successful, false if not
local function AddAfterRecText()
	if not QuestLogItemReceiveText:IsShown() then 
		return false;
	end
	xpText:SetPoint("LEFT", QuestLogItemReceiveText, "RIGHT", 5, 0);
	return true;
end

--- If choice or spell exists append recieve text after it and append xp text
-- @return true if successful, false if not
local function AddAfterSpellOrChoice()
	if not QuestLogItemChooseText:IsShown() and not QuestLogSpellLearnText:IsShown() then 
		return false;
	end
	
	local numQuestChoices = GetNumQuestLogChoices();
	if ( GetNumQuestLogRewardSpells() > 0  ) then
		QuestLogItemReceiveText:SetText(REWARD_ITEMS);
		QuestLogItemReceiveText:SetPoint("TOPLEFT", "QuestLogItem"..(numQuestChoices+1), "BOTTOMLEFT", 3, -5);
	else
		QuestLogItemReceiveText:SetText(REWARD_ITEMS);
		if ( mod(numQuestChoices, 2) == 0 ) then
			numQuestChoices = numQuestChoices - 1;
		end
		QuestLogItemReceiveText:SetPoint("TOPLEFT", "QuestLogItem"..numQuestChoices, "BOTTOMLEFT", 3, -5);
	end
	
	QuestLogItemReceiveText:Show();
	QuestFrame_SetAsLastShown(QuestLogItemReceiveText, QuestLogSpacerFrame);
	xpText:SetPoint("LEFT", QuestLogItemReceiveText, "RIGHT", 5, 0);
	return true;
end

--- Add reward section with xp text if there isn't a reward at all
-- @return true if successful, false if not
local function AddRewardSection()
	if QuestLogRewardTitleText:IsShown() then 
		return false;
	end
	QuestLogRewardTitleText:Show();
	QuestFrame_SetTitleTextColor(QuestLogRewardTitleText, QuestFrame_GetMaterial());
	QuestLogItemReceiveText:SetText(REWARD_ITEMS_ONLY);
	QuestLogItemReceiveText:SetPoint("TOPLEFT", "QuestLogRewardTitleText", "BOTTOMLEFT", 3, -5);
	QuestLogItemReceiveText:Show();
	QuestFrame_SetAsLastShown(QuestLogItemReceiveText, QuestLogSpacerFrame);
	xpText:SetPoint("LEFT", QuestLogItemReceiveText, "RIGHT", 5, 0);
	return true;
end

--- Try to anchor the XP FontString to a fitting position in quest details
-- @return true if successful, false if not
local function AddXpText()
	if AddAfterMoney() or AddAfterRecText() or AddAfterSpellOrChoice() or AddRewardSection() then 
		return true;
	end
	return false;
end

local OrigQuestLog_UpdateQuestDetails = QuestLog_UpdateQuestDetails
function QuestLog_UpdateQuestDetails(doNotScroll)
	OrigQuestLog_UpdateQuestDetails(doNotScroll);
	
	if UnitLevel("player") < 60 then
		local _, _, _, _, _, _, _, questID = GetQuestLogTitle(GetQuestLogSelection());
		if _addon.xpdata[questID] and AddXpText() then
			xpText:SetText(_addon.xpdata[questID] .. " XP");
			xpText:Show();
			return;
		end
	end

	xpText:Hide();
end