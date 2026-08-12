--連鎖解呪
-- 效果：
-- ①：魔法·陷阱卡发动时才能发动。从发动的那张魔法·陷阱卡的控制者卡组把同名卡全部破坏。
function c3171055.initial_effect(c)
	-- ①：魔法·陷阱卡发动时才能发动。从发动的那张魔法·陷阱卡的控制者卡组把同名卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c3171055.condition)
	e1:SetTarget(c3171055.target)
	e1:SetOperation(c3171055.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的条件判断：确保发动的是魔法·陷阱卡
function c3171055.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果处理时的准备阶段：检索发动卡同名卡并设置破坏操作信息
function c3171055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索发动卡同名卡并返回满足条件的卡组
	local g=Duel.GetMatchingGroup(Card.IsCode,ep,LOCATION_DECK,0,nil,re:GetHandler():GetCode())
	-- 设置连锁操作信息为破坏效果，并指定目标卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果发动时的处理阶段：将检索到的同名卡全部破坏
function c3171055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检索发动卡同名卡并返回满足条件的卡组
	local g=Duel.GetMatchingGroup(Card.IsCode,ep,LOCATION_DECK,0,nil,re:GetHandler():GetCode())
	-- 将目标卡组全部以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
