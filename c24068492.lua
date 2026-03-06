--自業自得
-- 效果：
-- ①：给与对方为对方场上的怪兽数量×500伤害。
function c24068492.initial_effect(c)
	-- ①：给与对方为对方场上的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c1)
	e1:SetTarget(c24068492.target)
	e1:SetOperation(c24068492.activate)
	c:RegisterEffect(e1)
end
-- 效果作用
function c24068492.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 将伤害对象设为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算对方场上的怪兽数量并乘以500作为伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)*500
	-- 将伤害值设为连锁对象参数
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果作用
function c24068492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算对方场上的怪兽数量并乘以500作为伤害值
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)*500
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
