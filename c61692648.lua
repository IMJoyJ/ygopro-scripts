--勇気機関車ブレイブポッポ
-- 效果：
-- ①：这张卡的攻击宣言时发动。这张卡的攻击力直到伤害步骤结束时变成原本攻击力的一半。
function c61692648.initial_effect(c)
	-- ①：这张卡的攻击宣言时发动。这张卡的攻击力直到伤害步骤结束时变成原本攻击力的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c61692648.atkop)
	c:RegisterEffect(e1)
end
-- 执行效果处理，若自身仍在场上表侧表示存在，则使其攻击力直到伤害步骤结束时变成原本攻击力的一半。
function c61692648.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到伤害步骤结束时变成原本攻击力的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(c:GetBaseAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
