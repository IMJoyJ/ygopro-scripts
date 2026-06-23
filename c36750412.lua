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
-- 效果发动条件：造成战斗伤害的玩家不是自己
function c36750412.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果处理：若此卡表侧表示且存在于场上，则使其攻击力上升200
function c36750412.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使此卡攻击力上升200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
