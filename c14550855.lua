--インフェルニティ・インフェルノ
-- 效果：
-- 自己最多2张手卡丢弃。那之后，这个效果丢弃的数量的名字带有「永火」的卡从卡组送去墓地。
function c14550855.initial_effect(c)
	-- 效果原文内容：自己最多2张手卡丢弃。那之后，这个效果丢弃的数量的名字带有「永火」的卡从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14550855.target)
	e1:SetOperation(c14550855.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡是否为名字带有「永火」且可以送去墓地的卡。
function c14550855.filter(c)
	return c:IsSetCard(0xb) and c:IsAbleToGrave()
end
-- 效果的发动时点处理函数，用于判断是否可以发动此效果。
function c14550855.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌数量是否大于0。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查自己卡组中是否存在至少1张名字带有「永火」且可以送去墓地的卡。
		and Duel.IsExistingMatchingCard(c14550855.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备处理丢弃手牌的效果。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置连锁操作信息：准备处理将卡从卡组送去墓地的效果。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果的发动处理函数，用于执行效果的处理流程。
function c14550855.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手牌数量是否为0，若为0则不执行后续操作。
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
	-- 统计自己卡组中名字带有「永火」且可以送去墓地的卡的数量。
	local ac=Duel.GetMatchingGroupCount(c14550855.filter,tp,LOCATION_DECK,0,nil)
	if ac==0 then return end
	if ac>2 then ac=2 end
	-- 丢弃自己手牌1到ac张（最多2张），丢弃原因包括丢弃和效果。
	local ct=Duel.DiscardHand(tp,aux.TRUE,1,ac,REASON_DISCARD+REASON_EFFECT)
	-- 中断当前效果处理，使之后的效果视为不同时处理。
	Duel.BreakEffect()
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择1到ct张名字带有「永火」且可以送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,c14550855.filter,tp,LOCATION_DECK,0,1,ct,nil)
	-- 将选中的卡送去墓地，原因来自效果。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
