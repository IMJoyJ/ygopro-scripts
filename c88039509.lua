--アイン・ロイド
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被战斗·效果破坏的场合才能发动。从卡组把2只4星以下的机械族怪兽送去墓地。
local s,id,o=GetID()
-- 注册该卡被破坏时发动的诱发效果：从卡组将2只4星以下机械族怪兽送去墓地
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被战斗·效果破坏的场合才能发动。从卡组把2只4星以下的机械族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡是否因战斗或效果被破坏
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：卡组中等级4以下、机械族且能送去墓地的怪兽
function s.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 效果发动时的目标选择与处理确认：检查卡组中是否存在至少2只满足条件的怪兽，并设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少2只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁处理的操作信息：将卡组的2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择2只满足条件的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查卡组中是否存在至少2只满足条件的怪兽，若不足则不处理
	if not Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,2,nil) then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择恰好2只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
