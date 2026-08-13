--バイサー・ショック
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，将场上的所有盖放的卡回到持有者的手卡。
function c17597059.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，将场上的所有盖放的卡回到持有者的手卡。
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
-- 过滤函数：判断一张卡是否为里侧表示且能够加入手卡（即场上所有里侧卡中可返回手牌的卡）。
function c17597059.filter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 诱发必发效果的目标函数：chk==0时直接返回true表示允许发动；随后检索场上所有满足filter的卡，并将“回手牌”的操作信息写入连锁（数量为检索到的卡数）。
function c17597059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取以tp视角看双方场上（LOCATION_ONFIELD）所有满足filter（里侧且可加入手卡）的卡，不除外任何卡。
	local g=Duel.GetMatchingGroup(c17597059.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：将g中的卡全部作为此次效果将要送回手牌的对象，数量为g:GetCount()，用于后续规则判定与检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：在效果处理时重新检索双方场上所有满足filter的卡，然后统一将它们返回持有者手卡。
function c17597059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 同目标阶段检索：再次获取双方场上所有里侧表示且可加入手卡的卡，作为实际处理的对象。
	local g=Duel.GetMatchingGroup(c17597059.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将g中的所有卡以“效果”为原因送回其持有者的手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
