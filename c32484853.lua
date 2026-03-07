--特異点の悪魔
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤时，从手卡把这张卡和1张魔法卡丢弃才能发动。那些怪兽破坏。
local s,id,o=GetID()
-- 注册触发效果，当对方特殊召唤怪兽时发动，满足条件则破坏对方特殊召唤的怪兽
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
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
-- 过滤函数，判断怪兽是否为对方召唤
function s.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果条件，判断是否有对方特殊召唤的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数，判断手牌中是否存在魔法卡
function s.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 效果代价，检查是否满足丢弃手牌和魔法卡的条件
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and
		-- 检查手牌中是否存在满足条件的魔法卡
		Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，判断怪兽是否为对方召唤且在场上
function s.desfilter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
		and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_MZONE)
end
-- 效果目标，设置要破坏的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.desfilter,1,nil,nil,tp) end
	local g=eg:Filter(s.desfilter,nil,nil,tp)
	-- 设置连锁处理的目标卡片
	Duel.SetTargetCard(eg)
	-- 设置操作信息，确定破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理，破坏符合条件的怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.desfilter,nil,e,tp):Filter(Card.IsRelateToChain,nil)
	-- 执行破坏操作
	Duel.Destroy(g,REASON_EFFECT)
end
