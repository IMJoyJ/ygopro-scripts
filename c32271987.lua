--フェデライザー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只二重怪兽送去墓地，从自己卡组抽1张卡。
function c32271987.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32271987,0))  --"送墓抽卡"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c32271987.condition)
	e1:SetTarget(c32271987.target)
	e1:SetOperation(c32271987.operation)
	c:RegisterEffect(e1)
end
-- 这张卡被战斗破坏送去墓地时
function c32271987.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 二重怪兽
function c32271987.filter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToGrave()
end
-- 检查是否可以发动效果
function c32271987.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算满足条件的二重怪兽数量
		local ct=Duel.GetMatchingGroupCount(c32271987.filter,tp,LOCATION_DECK,0,nil)
		-- 若卡组只剩一张卡且只有一张二重怪兽则不能发动
		if ct==1 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==1 then return false end
		-- 确认玩家可以抽卡且存在满足条件的二重怪兽
		return Duel.IsPlayerCanDraw(tp,1) and ct>=1 end
	-- 设置将要送去墓地的卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置将要抽卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数
function c32271987.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张满足条件的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c32271987.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 让玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
