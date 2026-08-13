--針千本
-- 效果：
-- 守备表示的这张卡受到攻击时，若这张卡的守备力超过对方攻击怪兽的攻击力，伤害步骤结束时那只攻击怪兽破坏。
function c33977496.initial_effect(c)
	-- 守备表示的这张卡受到攻击时，若这张卡的守备力超过对方攻击怪兽的攻击力，伤害步骤结束时那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33977496,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c33977496.condition)
	e1:SetTarget(c33977496.target)
	e1:SetOperation(c33977496.operation)
	c:RegisterEffect(e1)
end
-- 判断效果能否发动：攻击对象为这张卡、这张卡为守备表示，且攻击怪兽的攻击力小于这张卡的守备力。
function c33977496.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击对象是否为这张卡且这张卡处于守备表示。
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():IsDefensePos()
		-- 检查攻击怪兽的攻击力小于这张卡的守备力。
		and Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense()
end
-- 效果发动时的目标处理：直接返回true以允许发动，并设置破坏攻击怪兽的操作信息。
function c33977496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁将破坏攻击怪兽1只，操作分类为破坏效果（用于给其他卡响应时点提供信息）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 效果处理：获取攻击怪兽，若该怪兽仍与本次战斗关联，则以效果将其破坏。
function c33977496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击的怪兽并存入变量a。
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 以效果原因将攻击怪兽破坏。
	Duel.Destroy(a,REASON_EFFECT)
end
