--サイコロプス
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子，出现的数目的效果适用。
-- ●1：把对方手卡确认，从那之中选1张卡丢弃。
-- ●2～5：选自己1张手卡丢弃。
-- ●6：自己手卡全部丢弃。
function c62893810.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子，出现的数目的效果适用。●1：把对方手卡确认，从那之中选1张卡丢弃。●2～5：选自己1张手卡丢弃。●6：自己手卡全部丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c62893810.target)
	e1:SetOperation(c62893810.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测函数
function c62893810.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方手牌的卡片组，用于检测手牌是否为空
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	if chk==0 then return g1:GetCount()~=0 end
	-- 设置操作信息：投掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理函数，根据骰子结果适用对应效果
function c62893810.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 投掷1次骰子并获取结果
	local d=Duel.TossDice(tp,1)
	if d==1 then
		-- 获取对方手牌的卡片组
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if g:GetCount()==0 then return end
		-- 让发动效果的玩家确认对方手牌
		Duel.ConfirmCards(tp,g)
		-- 设置选择丢弃手牌的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的对方手牌因效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		-- 洗切对方手牌
		Duel.ShuffleHand(1-tp)
	elseif d==6 then
		-- 获取自己手牌的卡片组
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if g:GetCount()==0 then return end
		-- 将自己所有手牌因效果丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	elseif d>=2 and d<=5 then
		-- 获取自己手牌的卡片组
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		if g:GetCount()==0 then return end
		-- 设置选择丢弃手牌的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的自己手牌因效果丢弃送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		-- 洗切自己手牌
		Duel.ShuffleHand(tp)
	end
end
