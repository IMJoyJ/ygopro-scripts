--ビッグホーン・マンモス
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方场上怪兽召唤·反转召唤·特殊召唤的回合不能攻击。
function c59380081.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方场上怪兽召唤·反转召唤·特殊召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(c59380081.target)
	c:RegisterEffect(e1)
end
-- 过滤出在本回合召唤、反转召唤或特殊召唤的怪兽
function c59380081.target(e,c)
	return c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
