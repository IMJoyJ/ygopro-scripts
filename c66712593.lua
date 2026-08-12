--エレメント・ソルジャー
-- 效果：
-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。
-- ●水属性：这张卡的控制权不能变更。
-- ●地属性：这张卡战斗破坏的怪兽的效果无效化。
function c66712593.initial_effect(c)
	-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。●水属性：这张卡的控制权不能变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	e1:SetCondition(c66712593.ctlcon)
	c:RegisterEffect(e1)
	-- 这只怪兽在场上有特定属性的怪兽存在的场合，得到以下的效果。●地属性：这张卡战斗破坏的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c66712593.discon)
	e2:SetOperation(c66712593.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且为指定属性的怪兽
function c66712593.filter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 控制权变更效果的启用条件
function c66712593.ctlcon(e)
	-- 检查场上是否存在表侧表示的水属性怪兽
	return Duel.IsExistingMatchingCard(c66712593.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_WATER)
end
-- 效果无效化效果的触发条件：自身进行战斗且将对方怪兽战斗破坏，且场上存在地属性怪兽
function c66712593.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查场上是否存在表侧表示的地属性怪兽
		and Duel.IsExistingMatchingCard(c66712593.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,ATTRIBUTE_EARTH)
end
-- 效果无效化效果的执行操作：使被战斗破坏的怪兽效果无效化
function c66712593.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 这张卡战斗破坏的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e1)
	-- 这张卡战斗破坏的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+0x17a0000)
	bc:RegisterEffect(e2)
end
