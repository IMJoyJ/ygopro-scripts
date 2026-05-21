--手をつなぐ魔人
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
-- ②：这张卡的守备力上升这张卡以外的自己场上的表侧守备表示怪兽的原本守备力的合计数值。
function c94535485.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能选择其他怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c94535485.atlimit)
	c:RegisterEffect(e1)
	-- ②：这张卡的守备力上升这张卡以外的自己场上的表侧守备表示怪兽的原本守备力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c94535485.defval)
	c:RegisterEffect(e2)
end
-- 攻击目标限制判定：若目标怪兽不是这张卡自身，则不能被选择为攻击对象
function c94535485.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 过滤条件：原本守备力大于等于0且处于表侧守备表示的怪兽
function c94535485.deffilter(c)
	return c:GetBaseDefense()>=0 and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 守备力上升值计算：获取符合条件的怪兽并计算其原本守备力的合计数值
function c94535485.defval(e,c)
	-- 获取这张卡以外的自己场上的表侧守备表示怪兽
	local g=Duel.GetMatchingGroup(c94535485.deffilter,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetSum(Card.GetBaseDefense)
end
