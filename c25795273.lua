--イルミラージュ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力·守备力下降那怪兽的等级或者阶级×300。
function c25795273.initial_effect(c)
	-- 对应效果原文「①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力·守备力下降那怪兽的等级或者阶级×300。」中关于攻击力下降的部分；该段代码创建作用于全场怪兽的攻击力增减效果，数值由val函数提供。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(c25795273.val)
	c:RegisterEffect(e1)
	-- 对应效果原文「①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力·守备力下降那怪兽的等级或者阶级×300。」中关于守备力下降的部分；该段代码创建作用于全场怪兽的守备力增减效果，数值同样由val函数提供。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c25795273.val)
	c:RegisterEffect(e2)
end
-- 定义数值计算函数：若对象怪兽为超量怪兽则返回其阶级×-300，否则返回其等级×-300，用于实现攻击力·守备力下降对应数值的规则计算。
function c25795273.val(e,c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()*-300
	else
		return c:GetLevel()*-300
	end
end
