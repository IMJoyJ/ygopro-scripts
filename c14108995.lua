--春化精の花冠
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的地属性怪兽也当作「春化精」怪兽使用。
-- ②：1回合1次，自己为让手卡的「春化精」怪兽的效果发动而把那只怪兽和1张卡从手卡丢弃的场合，可以作为代替只把那只怪兽丢弃。
function c14108995.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的地属性怪兽也当作「春化精」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己为让手卡的「春化精」怪兽的效果发动而把那只怪兽和1张卡从手卡丢弃的场合，可以作为代替只把那只怪兽丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 检索满足条件的怪兽组（地属性怪兽）
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH))
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetValue(0x182)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己为让手卡的「春化精」怪兽的效果发动而把那只怪兽和1张卡从手卡丢弃的场合，可以作为代替只把那只怪兽丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(14108995)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
end
