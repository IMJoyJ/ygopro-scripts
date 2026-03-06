--仕込みマシンガン
-- 效果：
-- ①：给与对方为对方的手卡·场上的卡数量×200伤害。
function c27053506.initial_effect(c)
	-- ①：给与对方为对方的手卡·场上的卡数量×200伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27053506.target)
	e1:SetOperation(c27053506.activate)
	c:RegisterEffect(e1)
end
-- 效果作用
function c27053506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,0xe,1,nil) end
	-- 将连锁的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 计算对方手卡和场上的卡数量并乘以200作为伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,0xe,0)*200
	-- 将伤害值设置为连锁的目标参数
	Duel.SetTargetParam(dam)
	-- 设置连锁的操作信息为伤害效果，目标玩家为对方，伤害值为dam
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果作用
function c27053506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算对方手卡和场上的卡数量并乘以200作为伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,0xe,0)*200
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
