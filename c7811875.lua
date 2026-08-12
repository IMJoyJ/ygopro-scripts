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
-- 无效召唤效果的发动条件判定函数
function c7811875.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前是否没有处理中的连锁且召唤怪兽的玩家为对方
	return aux.NegateSummonCondition() and eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 过滤满足自己场上表侧表示、是同调怪兽且可以作为代价送去墓地条件的卡片
function c7811875.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价检测与处理函数
function c7811875.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检测自己场上是否存在符合送去墓地条件的同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7811875.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动效果的玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1只符合条件的同调怪兽
	local g=Duel.SelectMatchingCard(tp,c7811875.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将被选中的同调怪兽送去墓地作为发动的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 无效召唤效果的目标选择与发动检测函数
function c7811875.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	-- 设置连锁操作信息，声明该效果包含无效怪兽召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置连锁操作信息，声明该效果包含破坏目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理函数（无效召唤并破坏，并限制对方在这个回合召唤、特殊召唤、反转召唤）
function c7811875.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsSummonPlayer,nil,1-tp)
	-- 使对方正在进行的召唤、反转召唤、特殊召唤无效
	Duel.NegateSummon(g)
	-- 因效果破坏被无效召唤的怪兽
	Duel.Destroy(g,REASON_EFFECT)
	-- 这个回合，对方不能把怪兽召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	-- 注册在该回合内限制对方进行特殊召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 注册在该回合内限制对方进行通常召唤的玩家效果
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 注册在该回合内限制对方进行反转召唤的玩家效果
	Duel.RegisterEffect(e3,tp)
end
