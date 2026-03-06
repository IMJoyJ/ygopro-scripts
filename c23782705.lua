--マシンナーズ・スナイパー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，双方不能向「机甲狙击兵」以外的「机甲」怪兽攻击。
function c23782705.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，双方不能向「机甲狙击兵」以外的「机甲」怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c23782705.tg)
	-- 设置效果值为过滤函数aux.imval1，用于判断目标是否免疫该效果
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
-- 目标过滤函数，筛选出属于「机甲」卡组且不是机甲狙击兵本身的怪兽
function c23782705.tg(e,c)
	return c:IsSetCard(0x36) and not c:IsCode(23782705)
end
