--針三千本
-- 效果：
-- 守备表示的这张卡受到攻击的场合，若这张卡的守备力超过对方攻击怪兽的攻击力，伤害步骤结束时那只攻击怪兽破坏。
function c7852878.initial_effect(c)
	-- 守备表示的这张卡受到攻击的场合，若这张卡的守备力超过对方攻击怪兽的攻击力，伤害步骤结束时那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7852878,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c7852878.condition)
	e1:SetTarget(c7852878.target)
	e1:SetOperation(c7852878.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身在守备表示下受到攻击，且守备力超过对方攻击怪兽的攻击力
function c7852878.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否为被攻击对象且处于守备表示
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():IsDefensePos()
		-- 检查对方攻击怪兽的攻击力是否低于自身的守备力
		and Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense()
end
-- 设置效果发动的目标，声明将要破坏攻击怪兽
function c7852878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果在处理时会破坏1只攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 效果处理：将与本次战斗相关的攻击怪兽破坏
function c7852878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 因效果破坏该攻击怪兽
	Duel.Destroy(a,REASON_EFFECT)
end
