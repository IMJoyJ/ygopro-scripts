--ヴァイロン・チャージャー
-- 效果：
-- 自己场上表侧表示存在的光属性怪兽的攻击力上升这张卡装备的装备卡数量×300的数值。
function c13220032.initial_effect(c)
	-- 效果原文内容：自己场上表侧表示存在的光属性怪兽的攻击力上升这张卡装备的装备卡数量×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为自身场上表侧表示存在的光属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	e1:SetValue(c13220032.atkval)
	c:RegisterEffect(e1)
end
-- 定义攻击力上升值的计算函数，返回装备卡数量乘以300
function c13220032.atkval(e,c)
	return e:GetHandler():GetEquipCount()*300
end
