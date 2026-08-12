--逆巻く炎の精霊
-- 效果：
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，这张卡的攻击力上升1000。
function c90810762.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90810762,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c90810762.atkcon)
	e2:SetOperation(c90810762.atkop)
	c:RegisterEffect(e2)
end
-- 定义效果发动的条件函数：确认造成伤害的玩家是对方，且攻击对象为空（即直接攻击）
function c90810762.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方，且没有攻击目标（即直接攻击）
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义效果处理函数：若此卡仍在场上且表侧表示，则使其攻击力上升1000
function c90810762.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
