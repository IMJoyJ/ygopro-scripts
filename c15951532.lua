--アマゾネス女王
-- 效果：
-- ①：只要这张卡在怪兽区域存在，自己的「亚马逊」怪兽不会被战斗破坏。
function c15951532.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，自己的「亚马逊」怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 指定该效果只对自己场上的「亚马逊」怪兽适用（结合SetTargetRange已限定的我方怪兽区域，进一步筛选持有亚马逊字段的怪兽）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x4))
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
