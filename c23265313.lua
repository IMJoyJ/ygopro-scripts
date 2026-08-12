--コストダウン
-- 效果：
-- ①：丢弃1张手卡才能发动。这个回合，自己手卡的怪兽的等级下降2星。
function c23265313.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。这个回合，自己手卡的怪兽的等级下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c23265313.cost)
	e1:SetOperation(c23265313.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足丢弃手卡的条件并执行丢弃操作
function c23265313.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 发动效果：使自己手牌中等级高于1的怪兽等级下降2星，并注册持续效果
function c23265313.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己手牌中所有等级高于1的怪兽
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(Card.IsLevelAbove,nil,1)
	local tc=hg:GetFirst()
	while tc do
		-- 使手牌中的怪兽等级下降2星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
	-- 注册一个在怪兽进入手牌时触发的效果，用于持续使怪兽等级下降2星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c23265313.hlvop)
	-- 将效果注册到玩家全局环境中
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数：筛选出控制权为自己且等级高于1的卡
function c23265313.hlvfilter(c,tp)
	return c:IsLevelAbove(1) and c:IsControler(tp)
end
-- 当有卡进入手牌时，使这些卡的等级下降2星
function c23265313.hlvop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(c23265313.hlvfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		-- 使进入手牌的怪兽等级下降2星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
