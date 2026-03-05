--サンダー・ショート
-- 效果：
-- 对方场上存在的怪兽每有1只，给与对方基本分400分伤害。
function c20264508.initial_effect(c)
	-- 效果原文内容：对方场上存在的怪兽每有1只，给与对方基本分400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c20264508.target)
	e1:SetOperation(c20264508.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置连锁的处理目标为对方玩家，并计算伤害值。
function c20264508.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件（对方场上存在怪兽）。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0 end
	-- 效果作用：将连锁的目标玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 效果作用：计算对方场上怪兽数量乘以400作为伤害值。
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*400
	-- 效果作用：将计算出的伤害值设置为连锁的目标参数。
	Duel.SetTargetParam(dam)
	-- 效果作用：设置连锁的操作信息为伤害效果，目标为对方玩家，伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果原文内容：对方场上存在的怪兽每有1只，给与对方基本分400分伤害。
function c20264508.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：计算目标玩家场上怪兽数量乘以400作为实际伤害值。
	local dam=Duel.GetFieldGroupCount(p,LOCATION_MZONE,0)*400
	-- 效果作用：对目标玩家造成相应伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
