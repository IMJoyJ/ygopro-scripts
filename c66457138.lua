--ファーニマル・ライオ
-- 效果：
-- ①：这张卡的攻击宣言时发动。这张卡的攻击力直到战斗阶段结束时上升500。
function c66457138.initial_effect(c)
	-- ①：这张卡的攻击宣言时发动。这张卡的攻击力直到战斗阶段结束时上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c66457138.atkop)
	c:RegisterEffect(e1)
end
-- 攻击宣言时效果的处理：若此卡仍在场上表侧表示存在，则直到战斗阶段结束时其攻击力上升500
function c66457138.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到战斗阶段结束时上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
