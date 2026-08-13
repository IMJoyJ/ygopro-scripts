--ハーピィ・レディ2
-- 效果：
-- 这张卡的卡名当作「鹰身女郎」使用。这只怪兽战斗破坏的反转效果怪兽的效果无效化。
function c27927359.initial_effect(c)
	-- 这只怪兽战斗破坏的反转效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c27927359.operation)
	c:RegisterEffect(e1)
end
-- 此效果在伤害计算后（EVENT_BATTLED）触发：获取此卡的战斗对象，若对象处于战斗破坏确定状态且为反转效果怪兽，则给该对象注册EFFECT_DISABLE（使其怪兽效果无效）和EFFECT_DISABLE_EFFECT（使其效果无效）两个效果，并设置在离场等重置事件时解除无效状态，从而实现反转效果怪兽的效果无效化。
function c27927359.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsType(TYPE_FLIP) then
		-- 反转效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		bc:RegisterEffect(e2)
	end
end
