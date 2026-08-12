--ダーク・ヒーロー ゾンバイア
-- 效果：
-- ①：这张卡不能直接攻击。
-- ②：这张卡战斗破坏怪兽的场合发动。这张卡的攻击力下降200。
function c88472456.initial_effect(c)
	-- ①：这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽的场合发动。这张卡的攻击力下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(c88472456.atkop)
	c:RegisterEffect(e2)
end
-- 战斗破坏怪兽时发动效果的执行函数：验证自身是否在场，并为自身注册攻击力下降200的效果，该效果在自身离场或无效化等情况下重置。
function c88472456.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力下降200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
