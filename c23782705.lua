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
	-- 设置效果值为aux.imval1，使符合条件的「机甲」怪兽（不免疫此效果者）不能成为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
-- 过滤条件：持有「机甲」字段且卡号不是23782705（即「机甲狙击兵」）的怪兽，这类怪兽成为不能攻击的对象。
function c23782705.tg(e,c)
	return c:IsSetCard(0x36) and not c:IsCode(23782705)
end
