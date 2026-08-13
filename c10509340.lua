--古代の機械獣
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡战斗破坏的对方怪兽的效果无效化。
function c10509340.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏的对方怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c10509340.disop)
	c:RegisterEffect(e2)
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c10509340.aclimit)
	e3:SetCondition(c10509340.actcon)
	c:RegisterEffect(e3)
end
-- 本卡战斗破坏对方怪兽时，对那只怪兽分别赋予“效果无效”（EFFECT_DISABLE）与“效果的效果无效化”（EFFECT_DISABLE_EFFECT），且该无效状态在怪兽离场后重置。
function c10509340.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击目标怪兽。
	local d=Duel.GetAttackTarget()
	-- 若攻击目标为本卡（本卡为被攻击方），则将战斗对象改为攻击方怪兽，以确定与本卡交战的对方怪兽。
	if d==c then d=Duel.GetAttacker() end
	if not d or c:IsStatus(STATUS_BATTLE_DESTROYED) or not d:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	-- ②：这张卡战斗破坏的对方怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	d:RegisterEffect(e1)
	-- ②：这张卡战斗破坏的对方怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	d:RegisterEffect(e2)
end
-- 作为EFFECT_CANNOT_ACTIVATE的Value判定函数，返回对方发动的效果是否为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），是则不允许发动。
function c10509340.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 作为①效果的适用条件判断函数，返回当前存在攻击怪兽且攻击怪兽是否为本卡。
function c10509340.actcon(e)
	-- 判断当前攻击宣言的怪兽是否为本卡（Duel.GetAttacker()==e:GetHandler()），用于确定①效果的适用条件。
	return Duel.GetAttacker()==e:GetHandler()
end
