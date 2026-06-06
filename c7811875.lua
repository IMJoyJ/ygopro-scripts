--重力崩壊
-- 效果：
-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际，把自己场上1只表侧表示的同调怪兽送去墓地才能发动。那个无效，那些怪兽破坏。这个回合，对方不能把怪兽召唤·反转召唤·特殊召唤。
function c7811875.initial_effect(c)
	-- ①：对方把怪兽召唤·反转召唤·特殊召唤之际，把自己场上1只表侧表示的同调怪兽送去墓地才能发动。那个无效，那些怪兽破坏。这个回合，对方不能把怪兽召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON)
	e1:SetCondition(c7811875.condition)
	e1:SetCost(c7811875.cost)
	e1:SetTarget(c7811875.target)
	e1:SetOperation(c7811875.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e3)
end
-- 定义发动条件函数
function c7811875.condition(e,tp,eg,ep,ev,re,r,rp)
	return aux.NegateSummonCondition() and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤条件：自己场上表侧表示且能作为代价送去墓地的同调怪兽
function c7811875.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGraveAsCost()
end
-- 定义发动代价函数
function c7811875.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在至少1只满足条件的同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7811875.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只表侧表示的同调怪兽
	local g=Duel.SelectMatchingCard(tp,c7811875.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义效果目标函数
function c7811875.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置操作信息：破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果处理函数
function c7811875.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	Duel.NegateSummon(g)
	-- 破坏那些召唤被无效的怪兽
	Duel.Destroy(g,REASON_EFFECT)
	-- 这个回合，对方不能把怪兽召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	-- 注册限制对方特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册限制对方通常召唤的效果
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 注册限制对方反转召唤的效果
	Duel.RegisterEffect(e3,tp)
end
