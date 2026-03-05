--墓穴の道連れ
-- 效果：
-- ①：双方各自把对方手卡确认，从那之中选1张卡丢弃。那之后，双方各自从卡组抽1张。
function c16435215.initial_effect(c)
	-- 效果原文：①：双方各自把对方手卡确认，从那之中选1张卡丢弃。那之后，双方各自从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c16435215.condition)
	e1:SetTarget(c16435215.target)
	e1:SetOperation(c16435215.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件
function c16435215.condition(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsLocation(LOCATION_HAND) then
		-- 效果原文：双方各自把对方手卡确认，从那之中选1张卡丢弃。
		return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>1
	else
		-- 效果原文：双方各自把对方手卡确认，从那之中选1张卡丢弃。
		return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
	end
end
-- 效果作用：设置连锁处理时的确认信息
function c16435215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断双方是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 效果作用：设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
end
-- 效果作用：执行卡片效果的主要逻辑
function c16435215.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查双方手牌是否存在
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
	-- 效果作用：获取对方手牌组
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	-- 效果作用：获取己方手牌组
	local g2=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 效果作用：确认己方手牌
	Duel.ConfirmCards(tp,g1)
	-- 效果作用：确认对方手牌
	Duel.ConfirmCards(1-tp,g2)
	-- 效果作用：提示己方选择丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local sg1=g1:Select(tp,1,1,nil)
	-- 效果作用：提示对方选择丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local sg2=g2:Select(1-tp,1,1,nil)
	sg1:Merge(sg2)
	-- 效果作用：将选中的手牌送去墓地
	Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_DISCARD)
	-- 效果作用：洗切己方手牌
	Duel.ShuffleHand(tp)
	-- 效果作用：洗切对方手牌
	Duel.ShuffleHand(1-tp)
	-- 效果作用：中断当前效果处理
	Duel.BreakEffect()
	-- 效果作用：己方从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 效果作用：对方从卡组抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
