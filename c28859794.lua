--シールド・ウィング
-- 效果：
-- 这张卡1回合最多2次不会被战斗破坏。
function c28859794.initial_effect(c)
	-- 这张卡1回合最多2次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(2)
	e1:SetValue(c28859794.valcon)
	c:RegisterEffect(e1)
end
-- 此判定函数用于确认怪兽即将受到的破坏是否为战斗破坏。它检查破坏原因r中是否包含REASON_BATTLE标志，若包含则返回true，从而让EFFECT_INDESTRUCTABLE_COUNT效果消耗一次免疫次数并保护该怪兽不被这次战斗破坏。
function c28859794.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
