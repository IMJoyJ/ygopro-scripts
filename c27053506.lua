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
-- 效果发动时的目标选择函数，负责检查发动条件并预置伤害参数。
function c27053506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方的手卡或场上是否存在至少1张卡，作为发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,0xe,1,nil) end
	-- 将效果的对象玩家设置为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 计算对方手卡与场上的卡数量之和乘以200，作为伤害数值。
	local dam=Duel.GetFieldGroupCount(1-tp,0xe,0)*200
	-- 将计算得到的伤害数值设定为效果的对象参数。
	Duel.SetTargetParam(dam)
	-- 设置效果操作信息，声明即将对对方造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数，负责执行造成伤害的操作。
function c27053506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象玩家（即对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新计算对方手卡与场上的卡数量之和乘以200，作为实际伤害值。
	local dam=Duel.GetFieldGroupCount(1-tp,0xe,0)*200
	-- 对对象玩家造成计算出的效果伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
