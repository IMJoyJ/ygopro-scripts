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
-- 发动代价处理：从手卡丢弃1张卡作为发动COST（丢弃理由为COST+DISCARD）。
function c23265313.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己手卡存在至少1张可以丢弃的卡，以满足代价要求。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手卡选择1张卡丢弃到墓地（REASON_COST+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理：本回合自己手卡的怪兽等级下降2星；同时注册一个持续效果，使之后加入手卡的怪兽也被下降2星。
function c23265313.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己手卡中所有等级1以上的怪兽（作为当前需要下降等级的对象）。
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Filter(Card.IsLevelAbove,nil,1)
	local tc=hg:GetFirst()
	while tc do
		-- 这个回合，自己手卡的怪兽的等级下降2星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
	-- 这个回合，自己手卡的怪兽的等级下降2星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c23265313.hlvop)
	-- 将上述持续效果注册到场上，持续到结束阶段，监视本回合加入手卡的卡。
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：卡是等级1以上的怪兽，且控制者为自己（用于筛选新加入手卡的需要降星的怪兽）。
function c23265313.hlvfilter(c,tp)
	return c:IsLevelAbove(1) and c:IsControler(tp)
end
-- 持续效果处理：对满足条件的加入手卡的怪兽应用等级下降2星。
function c23265313.hlvop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(c23265313.hlvfilter,nil,tp)
	local tc=hg:GetFirst()
	while tc do
		-- 这个回合，自己手卡的怪兽的等级下降2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
