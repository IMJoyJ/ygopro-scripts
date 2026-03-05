--ゼロ・フォース
-- 效果：
-- 自己场上表侧表示存在的怪兽从游戏中除外时才能发动。场上表侧表示存在的全部怪兽的攻击力变成0。
function c17521642.initial_effect(c)
	-- 效果原文内容：自己场上表侧表示存在的怪兽从游戏中除外时才能发动。场上表侧表示存在的全部怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c17521642.condition)
	e1:SetTarget(c17521642.target)
	e1:SetOperation(c17521642.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查被除外的怪兽是否为我方控制且位于主要怪兽区且为表侧表示
function c17521642.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 规则层面作用：判断是否有满足条件的怪兽被除外
function c17521642.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17521642.cfilter,1,nil,tp)
end
-- 规则层面作用：筛选场上表侧表示且攻击力大于0的怪兽
function c17521642.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 规则层面作用：判断是否满足发动条件，即场上存在表侧表示且攻击力大于0的怪兽
function c17521642.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足发动条件，即场上存在表侧表示且攻击力大于0的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17521642.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 规则层面作用：将场上所有表侧表示的怪兽攻击力设为0
function c17521642.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取场上所有表侧表示的怪兽组成一个组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 效果原文内容：场上表侧表示存在的全部怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
