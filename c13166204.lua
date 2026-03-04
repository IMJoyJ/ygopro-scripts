--ガガガラッシュ
-- 效果：
-- 自己场上的名字带有「我我我」的怪兽成为对方怪兽的效果的对象时才能发动。那只对方怪兽的效果无效并破坏。那之后，给与对方基本分破坏的怪兽的攻击力和守备力之内较高方数值的伤害。
function c13166204.initial_effect(c)
	-- 效果原文内容：自己场上的名字带有「我我我」的怪兽成为对方怪兽的效果的对象时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetCondition(c13166204.condition)
	e1:SetTarget(c13166204.target)
	e1:SetOperation(c13166204.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：过滤满足条件的怪兽（表侧表示、在主要怪兽区、控制者为tp、名字带有「我我我」）
function c13166204.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x54)
end
-- 规则层面作用：判断是否满足发动条件（对方怪兽效果的对象、对方怪兽效果、己方有「我我我」怪兽、连锁效果可无效）
function c13166204.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查对方怪兽效果是否可无效，同时确认己方场上存在「我我我」怪兽作为效果对象
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and eg:IsExists(c13166204.filter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 规则层面作用：设置效果处理时的目标信息（使效果无效、破坏怪兽、造成伤害）
function c13166204.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置使对方怪兽效果无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：设置破坏对方怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
		-- 规则层面作用：设置对对方造成伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- 规则层面作用：设置效果发动后的处理流程（无效效果、破坏怪兽、计算并造成伤害）
function c13166204.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否成功使效果无效并破坏对方怪兽，若成功则继续计算伤害
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(re:GetHandler(),REASON_EFFECT)~=0 then
		local a=re:GetHandler():GetAttack()
		local b=re:GetHandler():GetDefense()
		if b>a then a=b end
		if a>0 then
			-- 规则层面作用：中断当前效果处理，使后续伤害处理视为错时点
			Duel.BreakEffect()
			-- 规则层面作用：对对方造成伤害，伤害值为被破坏怪兽攻击力与守备力中较高者
			Duel.Damage(1-tp,a,REASON_EFFECT)
		end
	end
end
