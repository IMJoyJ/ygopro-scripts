--特異点の悪魔
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤时，从手卡把这张卡和1张魔法卡丢弃才能发动。那些怪兽破坏。
local s,id,o=GetID()
-- 执行对应的效果条件检查或辅助函数处理
function s.initial_effect(c)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏特殊召唤的怪兽"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 执行对应的效果条件检查或辅助函数处理
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.desfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
		and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,nil,tp) end
	local g=eg:Filter(s.desfilter,nil,nil,tp)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetTargetCard(eg)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp):Filter(Card.IsRelateToChain,nil)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Destroy(g,REASON_EFFECT)
end
