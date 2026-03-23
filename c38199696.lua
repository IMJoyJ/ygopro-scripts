--レッド・ポーション
-- 效果：
-- 自己的基本分回复500。
function c38199696.initial_effect(c)
	-- 自己基本分回复500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38199696.rectg)
	e1:SetOperation(c38199696.recop)
	c:RegisterEffect(e1)
end
-- 效果处理时设置目标玩家和参数
function c38199696.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理连锁的目标玩家设置为使用该效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前处理连锁的目标参数设置为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为回复效果，目标玩家为tp，回复值为500
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果发动时执行的处理函数
function c38199696.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应参数值的LP，原因效果为REASON_EFFECT
	Duel.Recover(p,d,REASON_EFFECT)
end
