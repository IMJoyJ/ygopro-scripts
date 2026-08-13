--炎龍
-- 效果：
-- ①：这张卡给与对方战斗伤害的场合发动。这张卡的攻击力上升200。
function c36750412.initial_effect(c)
	-- ①：这张卡给与对方战斗伤害的场合发动。这张卡的攻击力上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36750412,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c36750412.atkcon)
	e1:SetOperation(c36750412.atkop)
	c:RegisterEffect(e1)
end
-- 判断造成战斗伤害的玩家是否为对方（即这张卡给与对方战斗伤害），满足发动条件。
function c36750412.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 在效果处理时，若这张卡仍与效果关联且处于表侧表示，则给予这张卡攻击力上升200的永续效果。
function c36750412.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
