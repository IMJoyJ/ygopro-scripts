--逆さ眼鏡
-- 效果：
-- 场上表侧表示存在的全部怪兽的攻击力直到结束阶段时变成一半。
function c94156050.initial_effect(c)
	-- 场上表侧表示存在的全部怪兽的攻击力直到结束阶段时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动的条件，限制在伤害步骤中只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c94156050.target)
	e1:SetOperation(c94156050.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标判定函数
function c94156050.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查双方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 定义效果运行的执行函数，使场上所有表侧表示怪兽的攻击力减半
function c94156050.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上当前所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到结束阶段时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
