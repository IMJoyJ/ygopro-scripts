--皆既日蝕の書
-- 效果：
-- ①：场上的表侧表示怪兽全部变成里侧守备表示。这个回合的结束阶段，对方场上的里侧守备表示怪兽全部变成表侧守备表示，那之后，对方从卡组抽出这个效果变成表侧守备表示的怪兽的数量。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：作为魔法卡在自由时点发动，效果分类为改变表示形式、抽卡和包含盖放，并指定目标函数与处理函数。
function s.initial_effect(c)
	-- 对应①效果原文：“①：场上的表侧表示怪兽全部变成里侧守备表示。这个回合的结束阶段，对方场上的里侧守备表示怪兽全部变成表侧守备表示，那之后，对方抽出这个效果变成表侧守备表示的怪兽的数量。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DRAW+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标处理：确认可以发动后，取得场上所有可以变成里侧守备表示的怪兽，并将本次连锁要改变这些怪兽表示形式的操作信息写入连锁。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：场上是否存在至少1只可以变成里侧守备表示的怪兽，有才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方主要怪兽区中所有可以变成里侧守备表示的怪兽，作为后续改变表示形式的对象。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：本次连锁将对这些怪兽执行表示形式变更，数量为怪兽总数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：先将场上所有可以变成里侧守备表示的怪兽全部变为里侧守备表示；再为发动玩家注册一个在结束阶段触发的持续效果，用于执行“对方里侧守备怪兽翻开并抽卡”的后续处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得场上所有可以变成里侧守备表示的怪兽，作为实际变更表示形式的对象。
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将取得的怪兽全部变成里侧守备表示。
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
	-- 对应效果原文后半句：“这个回合的结束阶段，对方场上的里侧守备表示怪兽全部变成表侧守备表示，那之后，对方抽出这个效果变成表侧守备表示的怪兽的数量。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(s.flipcon)
	e1:SetOperation(s.flipop)
	-- 将该持续效果注册到当前回合玩家（发动者）名下，使其在结束阶段满足条件时触发。
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段的后台条件判断：若对方场上有里侧守备表示怪兽，则执行后续翻转与抽卡处理。
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只里侧守备表示怪兽。
	return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil)
end
-- 结束阶段实际处理：展示“日全食之书”的卡图，取得对方场上的里侧守备表示怪兽，将其全部变成表侧守备表示；中断效果使抽卡另开时点；然后让对方抽出与变更数量相同的卡。
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示“日全食之书”的卡图，提示该效果正在处理。
	Duel.Hint(HINT_CARD,0,id)
	-- 取得对方场上所有里侧守备表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变为表侧守备表示，并返回实际改变表示形式的怪兽数量ct。
	local ct=Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	-- 中断当前效果处理，使“翻卡”与“抽卡”被视为不同时处理，避免错过时点。
	Duel.BreakEffect()
	-- 让对方玩家（1-tp）抽出ct张卡，抽卡原因视为效果。
	Duel.Draw(1-tp,ct,REASON_EFFECT)
end
