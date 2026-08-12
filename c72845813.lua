--A・O・J D.D.チェッカー
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方不能把光属性怪兽特殊召唤。
function c72845813.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方不能把光属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	-- 设置不能特殊召唤的对象为光属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	c:RegisterEffect(e1)
end
