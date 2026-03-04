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
	-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c10509340.disop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏的对方怪兽的效果无效化。
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
-- 效果作用：当此卡参与战斗时触发
function c10509340.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 若攻击目标为自身，则获取攻击怪兽
	if d==c then d=Duel.GetAttacker() end
	if not d or c:IsStatus(STATUS_BATTLE_DESTROYED) or not d:IsStatus(STATUS_BATTLE_DESTROYED) then return end
	-- 使被战斗破坏的对方怪兽效果无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	d:RegisterEffect(e1)
	-- 使被战斗破坏的对方怪兽效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	d:RegisterEffect(e2)
end
-- 效果作用：限制对方发动魔法·陷阱卡
function c10509340.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果作用：判断是否为攻击怪兽
function c10509340.actcon(e)
	-- 判断攻击怪兽是否为自身
	return Duel.GetAttacker()==e:GetHandler()
end
