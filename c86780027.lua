--一族の結束
-- 效果：
-- ①：自己墓地的全部怪兽的原本种族相同的场合，自己场上的那个种族的怪兽的攻击力上升800。
function c86780027.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己墓地的全部怪兽的原本种族相同的场合，自己场上的那个种族的怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c86780027.tg)
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
-- 作为永续效果的影响对象过滤函数，判断场上的怪兽是否满足攻击力上升的条件（自己墓地存在怪兽且原本种族全部相同，且该怪兽的种族与墓地怪兽的原本种族相同）。
function c86780027.tg(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取自己墓地的所有怪兽卡，用于后续判断种族是否单一。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	if g:GetCount()==0 or g:GetClassCount(Card.GetOriginalRace)>1 then return false end
	return c:IsRace(g:GetFirst():GetOriginalRace())
end
