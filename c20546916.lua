--ボタニカル・ライオ
-- 效果：
-- 自己场上表侧表示存在的植物族怪兽每有1只，这张卡的攻击力上升300。这张卡只要在场上表侧表示存在，控制权不能变更。
function c20546916.initial_effect(c)
	-- 自己场上表侧表示存在的植物族怪兽每有1只，这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c20546916.val)
	c:RegisterEffect(e1)
	-- 这张卡只要在场上表侧表示存在，控制权不能变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上表侧表示的植物族怪兽
function c20546916.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 计算场上植物族怪兽数量并乘以300作为攻击力提升值
function c20546916.val(e,c)
	-- 检索满足条件的植物族怪兽数量并乘以300
	return Duel.GetMatchingGroupCount(c20546916.filter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
