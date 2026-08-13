--星向鳥
-- 效果：
-- ①：这张卡只要在主要怪兽区域存在，得到那个位置的以下效果。
-- ●左端：这张卡的等级上升4星。
-- ●右端：这张卡的等级上升3星。
-- ●中央：这张卡的等级上升2星。
-- ●那以外：这张卡的等级上升1星。
function c34244455.initial_effect(c)
	-- ①：这张卡只要在主要怪兽区域存在，得到那个位置的以下效果。●左端：这张卡的等级上升4星。●右端：这张卡的等级上升3星。●中央：这张卡的等级上升2星。●那以外：这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetCondition(c34244455.lvcon)
	e1:SetValue(c34244455.lvval)
	c:RegisterEffect(e1)
end
-- 条件函数：判断这张卡是否位于主要怪兽区域（格子序号小于5，即0~4号位），是则允许适用位置对应的等级上升效果；序号5/6的额外怪兽区域不满足。
function c34244455.lvcon(e)
	return e:GetHandler():GetSequence()<5
end
-- 取值函数：根据卡片所在主怪兽区域的格子序号实际返回等级上升数值：序号0（左端）上升4星，序号4（右端）上升3星，序号2（中央）上升2星，其余序号（1、3）上升1星。
function c34244455.lvval(e,c)
	local seq=c:GetSequence()
	if seq==0 then return 4 end
	if seq==4 then return 3 end
	if seq==2 then return 2 end
	return 1
end
