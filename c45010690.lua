--フラボット
-- 效果：
-- ①：这张卡被送去墓地的场合发动。自己从卡组抽1张。那之后，1张手卡回到持有者卡组最上面。
function c45010690.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地的场合发动。自己从卡组抽1张。那之后，1张手卡回到持有者卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45010690,0))  --"把自己1张手卡放在卡组最上面"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c45010690.target)
	e1:SetOperation(c45010690.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置连锁处理时的目标玩家和参数，并设置操作信息，包括抽卡和将手卡送回卡组的效果。
function c45010690.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置当前连锁的目标玩家为处理该效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置当前连锁的目标参数为1。
	Duel.SetTargetParam(1)
	-- 效果作用：设置当前连锁的操作信息为抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 效果作用：设置当前连锁的操作信息为将1张手卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果作用：执行效果的处理流程，包括抽卡和选择手卡送回卡组。
function c45010690.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行抽卡操作，若未抽到卡则返回。
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 效果作用：中断当前效果处理，使后续处理视为错时点。
	Duel.BreakEffect()
	-- 效果作用：提示玩家选择要送回卡组的手卡。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择满足条件的手卡作为送回卡组的目标。
	local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
	-- 效果作用：将选中的手卡送回卡组顶端。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
end
