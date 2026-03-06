--武装神竜プロテクト・ドラゴン
-- 效果：
-- ①：这张卡的攻击力上升这张卡装备的装备卡数量×500。
-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的装备卡不会被效果破坏。
function c29330706.initial_effect(c)
	-- ②：只要这张卡在怪兽区域存在，自己场上的表侧表示的装备卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_SZONE,0)
	-- 设置效果目标为场上所有表侧表示的装备卡
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_EQUIP))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升这张卡装备的装备卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c29330706.val)
	c:RegisterEffect(e2)
end
-- 返回当前装备卡数量乘以500的数值
function c29330706.val(e,c)
	return c:GetEquipCount()*500
end
