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
-- 当此卡为对方怪兽攻击目标且此卡为守备表示，且对方攻击怪兽攻击力低于此卡守备力时发动
function c33977496.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当此卡为对方怪兽攻击目标且此卡为守备表示
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():IsDefensePos()
		-- 且对方攻击怪兽攻击力低于此卡守备力
		and Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense()
end
-- 设置连锁处理信息，确定将要破坏的攻击怪兽
function c33977496.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要破坏的攻击怪兽为当前攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 执行破坏效果，破坏攻击怪兽
function c33977496.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 将攻击怪兽因效果破坏
	Duel.Destroy(a,REASON_EFFECT)
end
