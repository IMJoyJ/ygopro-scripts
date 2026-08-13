--エンシェント・ドラゴン
-- 效果：
-- ①：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡的等级上升1星，攻击力上升500。
function c38520918.initial_effect(c)
	-- ①：这张卡直接攻击给与对方战斗伤害时才能发动。这张卡的等级上升1星，攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38520918,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c38520918.condition)
	e1:SetOperation(c38520918.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：该战斗伤害为这张卡直接攻击给与对方的战斗伤害（即伤害承受者为对方且攻击目标为空）。
function c38520918.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真当且仅当受到战斗伤害的是对方玩家（ep~=tp）且攻击目标为空（Duel.GetAttackTarget()==nil），即满足直接攻击条件。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 效果处理：先检查这张卡仍与效果关联且表侧表示，若成立则令其攻击力上升500，并复制该效果改为等级上升1星。
function c38520918.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(1)
		c:RegisterEffect(e2)
	end
end
