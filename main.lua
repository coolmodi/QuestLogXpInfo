local _, _addon = ...

local xpText;
local questLogPfx;

--- Append xp display after money reward if it's there
-- @return true if successful, false if not
local function AddAfterMoney()
	local moneyFrame = _G[questLogPfx.."MoneyFrame"];

	if not moneyFrame:IsShown() then
		return false;
	end

	xpText:SetPoint("LEFT", moneyFrame, "RIGHT", 0, 0);
	return true;
end

--- Append directly behind recieve text if it's there
-- @return true if successful, false if not
local function AddAfterRecText()
	local recFrame = _G[questLogPfx.."ItemReceiveText"];

	if not recFrame:IsShown() then
		return false;
	end

	xpText:SetPoint("LEFT", recFrame, "RIGHT", 5, 0);
	return true;
end

--- If choice or spell exists append recieve text after it and append xp text
-- @return true if successful, false if not
local function AddAfterSpellOrChoice()
	if not _G[questLogPfx.."ItemChooseText"]:IsShown() and not _G[questLogPfx.."SpellLearnText"]:IsShown() then 
		return false;
	end
	
	local recFrame = _G[questLogPfx.."ItemReceiveText"];
	local numQuestChoices = GetNumQuestLogChoices();
	if ( GetNumQuestLogRewardSpells() > 0  ) then
		recFrame:SetText(REWARD_ITEMS);
		recFrame:SetPoint("TOPLEFT", questLogPfx.."Item"..(numQuestChoices+1), "BOTTOMLEFT", 3, -5);
	else
		recFrame:SetText(REWARD_ITEMS);
		if ( mod(numQuestChoices, 2) == 0 ) then
			numQuestChoices = numQuestChoices - 1;
		end
		recFrame:SetPoint("TOPLEFT", questLogPfx.."Item"..numQuestChoices, "BOTTOMLEFT", 3, -5);
	end
	
	recFrame:Show();
	QuestFrame_SetAsLastShown(recFrame, _G[questLogPfx.."SpacerFrame"]);
	xpText:SetPoint("LEFT", recFrame, "RIGHT", 5, 0);
	return true;
end

--- Add reward section with xp text if there isn't a reward at all
-- @return true if successful, false if not
local function AddRewardSection()
	local titleText = _G[questLogPfx.."RewardTitleText"];

	if titleText:IsShown() then 
		return false;
	end
	titleText:Show();
	QuestFrame_SetTitleTextColor(titleText, QuestFrame_GetMaterial());

	local recFrame = _G[questLogPfx.."ItemReceiveText"];
	recFrame:SetText(REWARD_ITEMS_ONLY);
	recFrame:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 3, -5);
	recFrame:Show();
	QuestFrame_SetAsLastShown(recFrame, _G[questLogPfx.."SpacerFrame"]);
	xpText:SetPoint("LEFT", recFrame, "RIGHT", 5, 0);
	return true;
end

--- Insert XP info if applicable
local function QuestDetailUpdate()
	if UnitLevel("player") < 60 then
		local _, _, _, _, _, _, _, questID = GetQuestLogTitle(GetQuestLogSelection());
		if _addon.xpdata[questID] then
			xpText:ClearAllPoints();
			if AddAfterMoney() or AddAfterRecText() or AddAfterSpellOrChoice() or AddRewardSection() then 
				xpText:SetText(_addon.xpdata[questID] .. " XP");
				xpText:Show();
				return;
			end
		end
	end

	xpText:Hide();
end


-- Hook QuestLog Extended
if QuestLogEx ~= nil then
	questLogPfx = "QuestLogEx";
	local OrigQuestLog_UpdateQuestDetails = QuestLogEx.QuestLog_UpdateQuestDetails;
	xpText = QuestLogExDetailScrollChildFrame:CreateFontString("QXPIText", "BACKGROUND", "QuestFont");

	function QuestLogEx:QuestLog_UpdateQuestDetails(doNotScroll)
		OrigQuestLog_UpdateQuestDetails(doNotScroll);
		QuestDetailUpdate();
	end

-- Hook vanilla questlog
else
	questLogPfx = "QuestLog";
	local OrigQuestLog_UpdateQuestDetails = QuestLog_UpdateQuestDetails;
	xpText = QuestLogDetailScrollChildFrame:CreateFontString("QXPIText", "BACKGROUND", "QuestFont");

	function QuestLog_UpdateQuestDetails(doNotScroll)
		OrigQuestLog_UpdateQuestDetails(doNotScroll);
		QuestDetailUpdate();
	end
end

xpText:SetTextColor(0.15,0.15,0.15,1);
xpText:SetFont("Fonts\\FRIZQT__.TTF", 11);