--ヴェルズ・カストル
-- 效果：
-- 这张卡召唤成功的回合，自己在通常召唤外加上只有1次可以把1只名字带有「入魔」的怪兽召唤。
function c79785958.initial_effect(c)
	-- 这张卡召唤成功的回合，自己在通常召唤外加上只有1次可以把1只名字带有「入魔」的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c79785958.sumop)
	c:RegisterEffect(e1)
end
-- 召唤成功时，为玩家注册一个在回合结束前增加一次「入魔」怪兽通常召唤机会的效果，并注册已发动该效果的标记
function c79785958.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家本回合是否已经注册过该效果，若已注册则直接返回（实现“只有1次”的限制）
	if Duel.GetFlagEffect(tp,79785958)~=0 then return end
	-- 自己在通常召唤外加上只有1次可以把1只名字带有「入魔」的怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(79785958,0))  --"使用「入魔鬼·北河二」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 限制增加的通常召唤机会仅适用于名字带有「入魔」（卡片系列号为0xa）的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xa))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将增加通常召唤次数的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个在回合结束时重置的标识，用于记录本回合已适用过该效果
	Duel.RegisterFlagEffect(tp,79785958,RESET_PHASE+PHASE_END,0,1)
end
