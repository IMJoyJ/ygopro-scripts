--氷結界の虎将 ライホウ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方在场上发动的怪兽的效果的处理时，对方可以丢弃1张手卡。没丢弃的场合，那个效果无效化。
function c81275309.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方在场上发动的怪兽的效果的处理时，对方可以丢弃1张手卡。没丢弃的场合，那个效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(c81275309.handes)
	c:RegisterEffect(e1)
end
c81275309[0]=0
-- 在对方场上发动的怪兽效果处理时，处理对方是否丢弃手卡以及未丢弃时无效效果的逻辑
function c81275309.handes(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置和连锁ID
	local loc,id=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_CHAIN_ID)
	if ep==tp or loc~=LOCATION_MZONE or id==c81275309[0] or not re:IsActiveType(TYPE_MONSTER) then return end
	c81275309[0]=id
	-- 若对方手牌数大于0，则询问对方是否选择丢弃1张手牌
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(81275309,0)) then  --"是否要丢弃一张手牌？"
		-- 让对方选择并丢弃1张手牌
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD,nil)
		-- 中断效果处理，防止执行后续的无效化分支
		Duel.BreakEffect()
	-- 若对方没有丢弃手牌，则使该连锁的效果无效
	else Duel.NegateEffect(ev) end
end
