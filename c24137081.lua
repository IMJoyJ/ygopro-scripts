--ドリル・バーニカル
-- 效果：
-- 这张卡可以直接攻击对方玩家。每次这张卡直接攻击给与对方基本分战斗伤害，这张卡的攻击力上升1000。
function c24137081.initial_effect(c)
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 每次这张卡直接攻击给与对方基本分战斗伤害，这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24137081,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c24137081.atkcon)
	e2:SetOperation(c24137081.atkop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方玩家造成的战斗伤害且攻击对象为空
function c24137081.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方玩家造成的战斗伤害且攻击对象为空
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 满足条件时，使该卡攻击力上升1000
function c24137081.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使该卡攻击力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
