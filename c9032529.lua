--天使の涙
-- 效果：
-- ①：选自己1张手卡加入对方手卡。那之后，自己回复2000基本分。
function c9032529.initial_effect(c)
	-- ①：选自己1张手卡加入对方手卡。那之后，自己回复2000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c9032529.target)
	e1:SetOperation(c9032529.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的准备与检测，确认自己手卡数量大于0，并设置回复基本分的对象玩家和数值
function c9032529.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，确认自己手卡数量至少有1张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2000
	Duel.SetTargetParam(2000)
	-- 设置效果处理信息，表示该效果包含回复2000基本分的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
-- 效果处理，选择自己1张手卡加入对方手卡，之后自己回复2000基本分
function c9032529.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取自己当前的所有手卡
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	-- 向自己提示选择要交给对方的手卡
	Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(9032529,0))  --"请选择要交给对方的手卡"
	local sg=g:Select(p,1,1,nil)
	-- 如果成功将选中的手卡加入对方手卡
	if Duel.SendtoHand(sg,1-p,REASON_EFFECT)~=0 then
		-- 洗切自己的手卡
		Duel.ShuffleHand(p)
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 自己回复2000基本分
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
