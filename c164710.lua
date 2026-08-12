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
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c164710.lvop)
	c:RegisterEffect(e2)
end
-- 效果处理函数，用于处理等级下降效果
function c164710.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方手卡中等级大于等于1的怪兽
	local hg=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,LOCATION_HAND,LOCATION_HAND,nil,1)
	local tc=hg:GetFirst()
	while tc do
		-- 使目标怪兽的等级下降1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
	-- 注册一个在怪兽加入手牌时触发的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetOperation(c164710.hlvop)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 处理怪兽加入手牌时的等级下降效果
function c164710.hlvop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(Card.IsLevelAbove,nil,1)
	local tc=hg:GetFirst()
	while tc do
		-- 使目标怪兽的等级下降1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=hg:GetNext()
	end
end
