--皆既日蝕の書
-- 效果：
-- ①：场上的表侧表示怪兽全部变成里侧守备表示。这个回合的结束阶段，对方场上的里侧守备表示怪兽全部变成表侧守备表示，那之后，对方从卡组抽出这个效果变成表侧守备表示的怪兽的数量。
local s,id,o=GetID()
-- 初始化效果，创建一个永续效果，用于处理卡牌的发动和处理
function s.initial_effect(c)
	-- ①：场上的表侧表示怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果处理的判断函数，检查是否满足发动条件并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否场上存在可以变为里侧守备表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取所有可以变为里侧守备表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，表示将要改变怪兽表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果发动时的处理函数，将场上怪兽变为里侧守备表示并注册结束阶段效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有可以变为里侧守备表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将指定怪兽全部变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
	-- 注册结束阶段触发的效果，用于在结束阶段将对方怪兽变为表侧守备表示并抽卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(s.flipcon)
	e1:SetOperation(s.flipop)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段触发条件判断函数，检查对方是否有里侧守备表示的怪兽
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上是否存在里侧守备表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil)
end
-- 结束阶段触发时的处理函数，将对方里侧守备表示的怪兽变为表侧守备表示并让对方抽卡
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方发动了此卡
	Duel.Hint(HINT_CARD,0,id)
	-- 获取对方场上所有里侧守备表示的怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	-- 将对方里侧守备表示的怪兽变为表侧守备表示，并记录变化数量
	local ct=Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	-- 中断当前效果处理，使后续处理不与当前效果同时进行
	Duel.BreakEffect()
	-- 让对方从卡组抽出与表侧守备表示怪兽数量相同的卡数
	Duel.Draw(1-tp,ct,REASON_EFFECT)
end
