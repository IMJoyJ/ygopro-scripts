--カラクリ蜘蛛
-- 效果：
-- 这张卡攻击的怪兽是暗属性的场合，那只怪兽破坏，伤害的计算适用。
function c45688586.initial_effect(c)
	-- 这张卡攻击的怪兽是暗属性的场合，那只怪兽破坏，伤害的计算适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45688586,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(c45688586.target)
	e1:SetOperation(c45688586.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时点判定与操作信息登记：获取此卡及此卡的战斗对象；若此卡是攻击怪兽且战斗对象存在并属于暗属性，则允许发动，并登记将战斗对象破坏的操作信息。
function c45688586.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 发动条件：仅当此卡为攻击怪兽、其战斗对象存在且战斗对象为暗属性时，该效果才满足发动条件。
	if chk==0 then return c==Duel.GetAttacker() and bc and bc:IsAttribute(ATTRIBUTE_DARK) end
	-- 设置本次连锁的操作信息：要执行的是破坏效果，对象为此卡的战斗对象bc，数量为1，目标玩家和位置均暂定为0（因为对象已确定，这些参数在破坏效果中不被使用）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果处理时的操作：获取此卡及其战斗对象，若该战斗对象仍与本次战斗相关联（没有离场或关系被重置），则将其破坏。
function c45688586.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 以效果原因（REASON_EFFECT）将战斗对象bc破坏。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
