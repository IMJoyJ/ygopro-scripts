--サンダー・ショート
-- 效果：
-- 对方场上存在的怪兽每有1只，给与对方基本分400分伤害。
function c20264508.initial_effect(c)
	-- 对方场上存在的怪兽每有1只，给与对方基本分400分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(c20264508.target)
	e1:SetOperation(c20264508.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标处理：判断能否发动，将对象玩家设为对方，计算并存入伤害值。
function c20264508.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上必须存在怪兽，否则不满足发动条件。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)~=0 end
	-- 将当前连锁的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 根据对方场上怪兽数量计算基础伤害值：怪兽数×400。
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*400
	-- 将计算出的伤害值保存为连锁参数，供处理时使用。
	Duel.SetTargetParam(dam)
	-- 设置操作信息：本次效果为伤害效果，目标为对方玩家，预计伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理时的操作：取出对象玩家，按当前对方场上怪兽数计算伤害并给予伤害。
function c20264508.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出效果发动时设定的对象玩家（对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果处理时，以对方玩家为视角获取其场上的怪兽数量，重新计算伤害值。
	local dam=Duel.GetFieldGroupCount(p,LOCATION_MZONE,0)*400
	-- 给予对方玩家dam点效果伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
