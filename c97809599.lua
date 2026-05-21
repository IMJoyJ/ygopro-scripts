--旧神の印
-- 效果：
-- ①：支付1000基本分才能发动。对方场上盖放的卡全部确认。
function c97809599.initial_effect(c)
	-- ①：支付1000基本分才能发动。对方场上盖放的卡全部确认。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c97809599.cost)
	e1:SetTarget(c97809599.target)
	e1:SetOperation(c97809599.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价，用于检查和支付1000基本分
function c97809599.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 定义效果的目标，检查对方场上是否存在盖放的卡
function c97809599.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在至少1张盖放的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 定义效果的处理，获取并确认对方场上所有盖放的卡
function c97809599.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有盖放的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 让发动效果的玩家确认这些卡
		Duel.ConfirmCards(tp,g)
	end
end
