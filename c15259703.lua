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
-- 检查玩家是否能支付1000基本分并支付
function c15259703.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
