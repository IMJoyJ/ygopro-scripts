--氷結界の虎将 グルナード
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「冰结界」怪兽召唤。
function c9056100.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「冰结界」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9056100,0))  --"使用「冰结界的虎将 神兵」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤效果的适用对象为「冰结界」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	c:RegisterEffect(e1)
end
