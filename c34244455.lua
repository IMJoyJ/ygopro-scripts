--星向鳥
-- 效果：
-- ①：这张卡只要在主要怪兽区域存在，得到那个位置的以下效果。
-- ●左端：这张卡的等级上升4星。
-- ●右端：这张卡的等级上升3星。
-- ●中央：这张卡的等级上升2星。
-- ●那以外：这张卡的等级上升1星。
function c34244455.initial_effect(c)
	-- 创建一个永续效果，仅对自己生效，当此卡在主要怪兽区域时，根据其所在位置调整等级
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetCondition(c34244455.lvcon)
	e1:SetValue(c34244455.lvval)
	c:RegisterEffect(e1)
end
-- 条件函数：判断此卡是否在主要怪兽区域（序号小于5）
function c34244455.lvcon(e)
	return e:GetHandler():GetSequence()<5
end
-- 值函数：根据此卡在怪兽区域中的位置返回对应的等级提升值，左端(0)升4星，右端(4)升3星，中央(2)升2星，其余位置升1星
function c34244455.lvval(e,c)
	local seq=c:GetSequence()
	if seq==0 then return 4 end
	if seq==4 then return 3 end
	if seq==2 then return 2 end
	return 1
end
