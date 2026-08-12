--バイサー・ショック
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，将场上的所有盖放的卡回到持有者的手卡。
function c17597059.initial_effect(c)
	-- 这张卡通常召唤成功时，将场上的所有盖放的卡回到持有者的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17597059,0))  --"返回手牌"
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c17597059.target)
	e1:SetOperation(c17597059.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断卡片是否为里侧表示且可以送去手卡。
function c17597059.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 效果处理时，检索场上所有满足条件的盖放卡片，并设置操作信息。
function c17597059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有里侧表示且可以送去手卡的卡片组。
	local g=Duel.GetMatchingGroup(c17597059.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息为回手牌效果，目标为上述卡片组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果发动时，将场上所有满足条件的盖放卡片送去手卡。
function c17597059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有里侧表示且可以送去手卡的卡片组。
	local g=Duel.GetMatchingGroup(c17597059.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将指定卡片组以效果原因送去手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
