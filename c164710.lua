--小人のいたずら
-- 效果：
-- ①：这个回合，双方手卡的怪兽的等级下降1星。
-- ②：把墓地的这张卡除外才能发动。这个回合，双方手卡的怪兽的等级下降1星。
function c164710.initial_effect(c)
	-- ①：这个回合，双方手卡的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetOperation(c164710.lvop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。这个回合，双方手卡的怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	-- 设置效果②的发动代价为把墓地中的这张卡除外（aux.bfgcost实现除外自身作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c164710.lvop)
	c:RegisterEffect(e2)
end
-- 效果①和②共用的处理操作：获取双方手卡中所有等级≥1的怪兽，分别赋予等级下降1星的效果，并注册持续效果使本回合后续加入手卡的怪兽也获得相同下降。
function c164710.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索双方手卡中所有等级≥1的怪兽（无额外排除卡）作为要下降等级的对象集合。
	local hg=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,LOCATION_HAND,LOCATION_HAND,nil,1)
	local tc=hg:GetFirst()
	while tc do
		-- 这个回合，双方手卡的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
	-- 这个回合，双方手卡的怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c164710.hlvop)
	-- 将上述持续效果注册到当前玩家场上，使本回合每当有怪兽卡加入手卡时自动触发c164710.hlvop。
	Duel.RegisterEffect(e2,tp)
end
-- 持续效果触发后的处理：过滤出本次加入手卡且等级≥1的怪兽，为它们各赋予等级下降1星的效果。
function c164710.hlvop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(Card.IsLevelAbove,nil,1)
	local tc=hg:GetFirst()
	while tc do
		-- 这个回合，双方手卡的怪兽的等级下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
