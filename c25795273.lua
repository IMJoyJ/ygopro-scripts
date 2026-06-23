--イルミラージュ
-- 效果：
-- ①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力·守备力下降那怪兽的等级或者阶级×300。
function c25795273.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力·守备力下降那怪兽的等级或者阶级×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(c25795273.val)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，场上的怪兽的攻击力·守备力下降那怪兽的等级或者阶级×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(c25795273.val)
	c:RegisterEffect(e2)
end
-- 计算场上怪兽因光角幻兔效果而减少的攻击力或守备力，超量怪兽按阶级×300，其他怪兽按等级×300。
function c25795273.val(e,c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()*-300
	else
		return c:GetLevel()*-300
	end
end
