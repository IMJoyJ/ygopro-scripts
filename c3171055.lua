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
-- 发动条件：仅当连锁中的效果是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）时，本卡才能发动。
function c3171055.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 发动时处理：先允许发动，然后检索发动的那张魔法·陷阱卡的控制者卡组中与其同名的卡，并设置破坏这些卡的操作信息。
function c3171055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取从发动卡控制者（ep）的卡组中，卡名与发动的那张魔法·陷阱卡当前卡号相同的所有卡。
	local g=Duel.GetMatchingGroup(Card.IsCode,ep,LOCATION_DECK,0,nil,re:GetHandler():GetCode())
	-- 将检索到的同名卡组设置为本次效果要破坏的对象，并登记数量，用于连锁处理时的效果判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时：再次从发动卡控制者的卡组中获取同名卡，并将它们全部破坏。
function c3171055.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新获取发动卡控制者卡组中与发动卡同名的所有卡。
	local g=Duel.GetMatchingGroup(Card.IsCode,ep,LOCATION_DECK,0,nil,re:GetHandler():GetCode())
	-- 以效果原因（REASON_EFFECT）将获取到的同名卡全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
