--針二千本
-- 效果：
-- 守备表示的这张卡受到攻击时，若这张卡的守备力超过对方攻击怪兽的攻击力，伤害计算后那只攻击怪兽破坏。
function c83228073.initial_effect(c)
	-- 守备表示的这张卡受到攻击时，若这张卡的守备力超过对方攻击怪兽的攻击力，伤害计算后那只攻击怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83228073,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c83228073.condition)
	e1:SetTarget(c83228073.target)
	e1:SetOperation(c83228073.operation)
	c:RegisterEffect(e1)
end
-- 检查效果发动的条件：自身为守备表示且被攻击，且守备力超过对方攻击怪兽的攻击力
function c83228073.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查被攻击的怪兽是否是自身，且自身是否为守备表示
	return Duel.GetAttackTarget()==e:GetHandler() and e:GetHandler():IsDefensePos()
		-- 检查对方攻击怪兽的攻击力是否小于自身的守备力
		and Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense()
end
-- 效果发动的目标处理，设置破坏攻击怪兽的操作信息
function c83228073.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果将破坏1只攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 效果处理的执行函数，若攻击怪兽仍在战斗中则将其破坏
function c83228073.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 因效果破坏该攻击怪兽
	Duel.Destroy(a,REASON_EFFECT)
end
