--赤酢の踏切
-- 效果：
-- ①：「赤醋的道口」在自己场上只能有1张表侧表示存在。
-- ②：和盖放的这张卡相同纵列有对方的卡存在的场合才能把这张卡发动。和这张卡相同纵列的除这张卡以外的卡全部回到持有者手卡。
-- ③：只要这张卡在魔法与陷阱区域存在，和这张卡相同纵列的没有使用的区域不能使用。
function c65107325.initial_effect(c)
	c:SetUniqueOnField(1,0,65107325)
	-- ②：和盖放的这张卡相同纵列有对方的卡存在的场合才能把这张卡发动。和这张卡相同纵列的除这张卡以外的卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c65107325.condition)
	e1:SetTarget(c65107325.target)
	e1:SetOperation(c65107325.operation)
	c:RegisterEffect(e1)
	-- ③：只要这张卡在魔法与陷阱区域存在，和这张卡相同纵列的没有使用的区域不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c65107325.disval)
	c:RegisterEffect(e2)
end
-- 计算并返回与这张卡相同纵列的场上区域，用于使这些未使用的区域不能使用
function c65107325.disval(e,tp)
	local c=e:GetHandler()
	return c:GetColumnZone(LOCATION_ONFIELD,0)
end
-- 检查这张卡是否在魔陷区盖放，且其相同纵列是否存在对方控制的卡，作为发动的条件
function c65107325.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and c:IsFacedown()
		and c:GetColumnGroup():IsExists(Card.IsControler,1,nil,1-tp)
end
-- 检查相同纵列是否存在其他卡，并设置将这些卡送回手牌的操作信息
function c65107325.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	if chk==0 then return #g>0 end
	-- 设置当前连锁的处理信息为将相同纵列的除这张卡以外的所有卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 获取与这张卡相同纵列的除这张卡以外的所有卡，并将其全部送回持有者的手牌
function c65107325.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetColumnGroup()
	-- 将目标卡片组以效果原因送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
