local T, C, L = unpack(TKUI)
if C.automation.zone_track ~= true then return end

----------------------------------------------------------------------------------------
--	Auto Track Quests by Zone (based on Zoned Quests by zestyquarks)
----------------------------------------------------------------------------------------

local ql = C_QuestLog
local cf, ta, aq, rq, iw, gi, gn, qu, gq, ic, hs, d, db = CreateFrame, C_Timer.After, ql.AddQuestWatch, ql.RemoveQuestWatch, ql.IsWorldQuest, ql.GetInfo, ql.GetNumQuestLogEntries, QuestFrameProgressItems_Update, GetQuestID, InCombatLockdown, hooksecurefunc

local hd  = {
  [24636] = true}

hs(ql, "AddQuestWatch",    function(i, _, c) if db and not c then db[i]    = true end end)
hs(ql, "RemoveQuestWatch", function(i, _, c) if db and not c then db[i]    = nil  end end)
hs(    "CompleteQuest",    function()        if db           then db[gq()] = nil  end end)

local function upd()
  if ic() or not d then ta(0.5, upd) d = true return end

  if not db then
    ZonedQuestsDB = ZonedQuestsDB or {}
    db            = ZonedQuestsDB
  end

  local q, f

  for i = 1, gn() do
    q = gi(i)

    if q and not q.isHidden and not q.isHeader and not iw(q.questID) then
      f = (q.isOnMap or hd[q.questID] or db[q.questID]) and aq or rq f(q.questID, nil, true)
    end
  end

  qu() d = nil
end

local f = cf"Frame"
f:RegisterEvent"QUEST_ACCEPTED"
f:RegisterEvent"AREA_POIS_UPDATED"
f:RegisterEvent"PLAYER_ENTERING_WORLD"
f:SetScript("OnEvent", upd)