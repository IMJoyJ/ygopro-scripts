--ジョーズマン
-- 效果：
-- 这张卡不能特殊召唤。这张卡上级召唤的场合，解放的怪兽必须是水属性怪兽。这张卡的攻击力上升这张卡以外的自己场上表侧表示存在的水属性怪兽每1只300。
function c50532786.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡上级召唤的场合，解放的怪兽必须是水属性怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c50532786.tlimit)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力上升这张卡以外的自己场上表侧表示存在的水属性怪兽每1只300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c50532786.atkup)
	c:RegisterEffect(e3)
end
-- 效果作用：限制上级召唤时解放的怪兽必须是水属性。
function c50532786.tlimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果作用：用于筛选自己场上表侧表示的水属性怪兽。
function c50532786.atkfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果作用：计算自己场上表侧表示的水属性怪兽数量并乘以300作为攻击力提升值。
function c50532786.atkup(e,c)
	-- 检索满足条件的水属性表侧表示怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(c50532786.atkfilter,c:GetControler(),LOCATION_MZONE,0,c)*300
end
