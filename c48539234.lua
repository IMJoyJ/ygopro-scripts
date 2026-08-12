--便乗
-- 效果：
-- 对方在抽卡阶段以外抽卡时才能发动。那之后，每次对方在抽卡阶段以外抽卡，从自己卡组抽2张卡。
function c48539234.initial_effect(c)
	-- 对方在抽卡阶段以外抽卡时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c48539234.condition)
	c:RegisterEffect(e1)
	-- 那之后，每次对方在抽卡阶段以外抽卡，从自己卡组抽2张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(c48539234.condition)
	e2:SetOperation(c48539234.operation)
	c:RegisterEffect(e2)
end
-- 效果条件判断函数，用于判断是否满足发动条件
function c48539234.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断抽卡的玩家不是自己且当前阶段不是抽卡阶段
	return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
-- 效果处理函数，用于执行抽卡效果
function c48539234.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示对方本卡被发动
	Duel.Hint(HINT_CARD,0,48539234)
	-- 让自己从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
