--マインド・ハック
-- 效果：
-- 支付500基本分。对方的手卡和对方场上盖放的卡全部确认。
function c75392615.initial_effect(c)
	-- 支付500基本分。对方的手卡和对方场上盖放的卡全部确认。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c75392615.cost)
	e1:SetTarget(c75392615.target)
	e1:SetOperation(c75392615.operation)
	c:RegisterEffect(e1)
end
-- 支付500基本分的Cost函数
function c75392615.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤场上里侧表示的卡片以及手牌中非公开状态的卡片
function c75392615.filter(c)
	return (c:IsOnField() and c:IsFacedown()) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic())
end
-- 效果发动的Target函数，用于检查是否存在可确认的卡片
function c75392615.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌和对方场上是否存在至少1张可以确认的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c75392615.filter,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
end
-- 效果处理的Operation函数，用于确认对方手牌和场上盖放的卡并洗牌
function c75392615.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌和对方场上盖放的卡片组
	local g=Duel.GetMatchingGroup(c75392615.filter,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
	-- 让发动效果的玩家确认这些卡片
	Duel.ConfirmCards(tp,g)
	-- 洗切对方的手牌
	Duel.ShuffleHand(1-tp)
end
