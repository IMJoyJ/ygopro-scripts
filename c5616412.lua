--カウンターパンチ
-- 效果：
-- 被攻击的怪兽的守备力比对方攻击怪兽攻击力高的场合，伤害步骤结束后那个攻击的怪兽破坏。（伤害计算适用）
function c5616412.initial_effect(c)
	-- 被攻击的怪兽的守备力比对方攻击怪兽攻击力高的场合，伤害步骤结束后那个攻击的怪兽破坏。（伤害计算适用）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c5616412.condition)
	e1:SetTarget(c5616412.target)
	e1:SetOperation(c5616412.activate)
	c:RegisterEffect(e1)
end
-- 判断发动条件：在伤害步骤结束时，被攻击的守备表示怪兽的守备力高于对方攻击怪兽的攻击力，且双方怪兽均未因战斗离场
function c5616412.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗中被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return d and a:IsControler(1-tp) and a:IsRelateToBattle()
		and d:IsDefensePos() and d:IsRelateToBattle() and d:GetDefense()>a:GetAttack()
end
-- 定义效果发动的目标：将攻击怪兽设为效果处理对象，并声明破坏该怪兽的操作信息
function c5616412.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将进行攻击的怪兽设定为本效果的处理对象
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置效果处理信息，声明此效果将破坏1只攻击怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 定义效果处理：若作为对象的攻击怪兽依然存在于场上，则将其破坏
function c5616412.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前设定为效果处理对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将该攻击怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
