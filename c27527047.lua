--氷結界の御庭番
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的「冰结界」怪兽作为怪兽的效果的对象。
function c27527047.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能把自己场上的「冰结界」怪兽作为怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果的对象筛选条件：仅允许以我方场上的「冰结界」怪兽作为适用对象。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2f))
	e1:SetValue(c27527047.tgval)
	c:RegisterEffect(e1)
end
-- 判定效果发动方与类型：若效果由对方玩家发动且为怪兽效果，则本效果赋予的“不能成为对象”保护适用。
function c27527047.tgval(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
