--レッド・ポーション
-- 效果：
-- 自己的基本分回复500。
function c38199696.initial_effect(c)
	-- 自己的基本分回复500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38199696.rectg)
	e1:SetOperation(c38199696.recop)
	c:RegisterEffect(e1)
end
-- 效果作用
function c38199696.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设置为使用者
	Duel.SetTargetPlayer(tp)
	-- 将效果的对象参数设置为500
	Duel.SetTargetParam(500)
	-- 设置连锁的操作信息为回复效果，对象玩家为使用者，回复值为500
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果作用
function c38199696.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的对象玩家和参数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使对象玩家回复参数值的LP，原因视为效果
	Duel.Recover(p,d,REASON_EFFECT)
end
