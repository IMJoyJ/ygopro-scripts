--デス・カンガルー
-- 效果：
-- ①：向守备表示的这张卡进行攻击的怪兽的攻击力比这张卡的守备力低的场合，那次伤害步骤结束时发动。那只怪兽破坏。
function c78613627.initial_effect(c)
	-- ①：向守备表示的这张卡进行攻击的怪兽的攻击力比这张卡的守备力低的场合，那次伤害步骤结束时发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78613627,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c78613627.condition)
	e1:SetTarget(c78613627.target)
	e1:SetOperation(c78613627.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：伤害步骤结束时，自身作为被攻击怪兽，且战斗前为守备表示，且攻击怪兽的攻击力低于自身的守备力
function c78613627.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在伤害步骤结束时且自身仍与战斗关联，并且自身是本次战斗的被攻击对象
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttackTarget()==e:GetHandler()
		and bit.band(e:GetHandler():GetBattlePosition(),POS_DEFENSE)~=0
		-- 判断攻击怪兽的攻击力是否低于自身的守备力
		and Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense()
end
-- 效果发动时的处理：设置破坏攻击怪兽的操作信息
function c78613627.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理为破坏1只攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 效果处理：获取攻击怪兽，若其仍与战斗关联，则将其破坏
function c78613627.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 因效果将该攻击怪兽破坏
	Duel.Destroy(a,REASON_EFFECT)
end
