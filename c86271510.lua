--機怪獣ダレトン
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。这张卡的原本攻击力直到对方回合结束时变成场上的怪兽的攻击力和原本攻击力的相差数值合计数值。
function c86271510.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。这张卡的原本攻击力直到对方回合结束时变成场上的怪兽的攻击力和原本攻击力的相差数值合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c86271510.target)
	e1:SetOperation(c86271510.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且当前攻击力与原本攻击力不同的怪兽
function c86271510.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 效果发动的目标检查与可行性判断
function c86271510.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只当前攻击力与原本攻击力不同的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86271510.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理：计算双方场上所有表侧表示怪兽的攻击力与原本攻击力差值的绝对值之和，并以此数值重置这张卡的原本攻击力
function c86271510.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local atk=0
	while tc do
		local batk=tc:GetBaseAttack()
		local catk=tc:GetAttack()
		atk=math.abs(catk-batk)+atk
		tc=g:GetNext()
	end
	-- 这张卡的原本攻击力直到对方回合结束时变成场上的怪兽的攻击力和原本攻击力的相差数值合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	c:RegisterEffect(e1)
end
