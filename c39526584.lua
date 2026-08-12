--ギフトカード
-- 效果：
-- 对方回复3000基本分。
function c39526584.initial_effect(c)
	-- 对方回复3000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39526584.target)
	e1:SetOperation(c39526584.activate)
	c:RegisterEffect(e1)
end
-- 效果处理时点，设置连锁目标玩家和参数
function c39526584.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为3000
	Duel.SetTargetParam(3000)
	-- 设置连锁操作信息为对方回复3000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,3000)
end
-- 效果发动时点，获取目标玩家和参数并执行回复效果
function c39526584.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
