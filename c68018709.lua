--失楽の聖女
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己在对方回合可以把1张速攻魔法卡从手卡发动。
function c68018709.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：只要这张卡在怪兽区域存在，自己在对方回合可以把1张速攻魔法卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68018709,0))  --"适用「失乐之圣女」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1,68018709+EFFECT_COUNT_CODE_DUEL)
	c:RegisterEffect(e1)
end
