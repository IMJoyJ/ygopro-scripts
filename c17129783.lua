--セイクリッド・レオニス
-- 效果：
-- 只要这张卡在场上表侧表示存在，自己的主要阶段时只有1次，自己在通常召唤外加上可以把1只名字带有「星圣」的怪兽召唤。
function c17129783.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，自己的主要阶段时只有1次，自己在通常召唤外加上可以把1只名字带有「星圣」的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17129783,0))  --"使用「星圣·轩辕十四」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果目标为名字带有「星圣」的卡片
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x53))
	c:RegisterEffect(e1)
end
