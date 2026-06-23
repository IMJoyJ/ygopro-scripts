--素早いマンボウ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己卡组把1只鱼族怪兽送去墓地。那之后，可以从自己卡组把1只「迅捷翻车鱼」特殊召唤。
function c2843014.initial_effect(c)
	-- 诱发必发效果，对应一速的【被战斗破坏送去墓地时】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2843014,0))  --"送墓"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c2843014.condition)
	e1:SetTarget(c2843014.target)
	e1:SetOperation(c2843014.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡在墓地且因战斗破坏
function c2843014.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果处理的准备：设置将从自己卡组送去墓地的卡
function c2843014.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将1张卡从自己卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数：选择可以送去墓地的鱼族怪兽
function c2843014.filter1(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToGrave()
end
-- 过滤函数：选择可以特殊召唤的「迅捷翻车鱼」
function c2843014.filter2(c,e,tp)
	return c:IsCode(2843014) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：检索满足条件的鱼族怪兽送去墓地，然后选择是否特殊召唤1只「迅捷翻车鱼」
function c2843014.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只鱼族怪兽
	local g=Duel.SelectMatchingCard(tp,c2843014.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的鱼族怪兽送去墓地
	if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		if ft<=0 then return end
		-- 从自己卡组检索1只「迅捷翻车鱼」
		local tc=Duel.GetFirstMatchingCard(c2843014.filter2,tp,LOCATION_DECK,0,nil,e,tp)
		-- 询问玩家是否特殊召唤「迅捷翻车鱼」
		if tc and Duel.SelectYesNo(tp,aux.Stringid(2843014,1)) then  --"是否要特殊召唤「迅捷翻车鱼」？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将符合条件的「迅捷翻车鱼」特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
