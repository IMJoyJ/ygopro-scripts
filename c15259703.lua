--トゥーン・ワールド
-- 效果：
-- 支付1000基本分才能把这张卡发动。
function c15259703.initial_effect(c)
	-- 支付1000基本分才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c15259703.cost)
	c:RegisterEffect(e1)
end
-- 作为发动代价的判定与支付函数：先检查能否支付1000基本分，若可以则在实际发动时支付1000基本分。
function c15259703.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段（chk==0）检查玩家tp是否能支付1000基本分，若能则返回true以允许发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 在效果发动处理时让玩家tp实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
