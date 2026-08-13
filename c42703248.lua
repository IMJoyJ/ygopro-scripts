--ハリケーン
-- 效果：
-- 场上的魔法·陷阱卡全部回到持有者手卡。
function c42703248.initial_effect(c)
	-- 场上的魔法·陷阱卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42703248.target)
	e1:SetOperation(c42703248.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：卡片须为魔法·陷阱卡，且能够加入持有者手卡。
function c42703248.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标检查与操作信息设置：确认场上存在除自身外可回手的魔法·陷阱卡，并将这些卡登记为回手牌的操作对象。
function c42703248.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：场上是否存在除自身以外至少1张符合条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c42703248.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 取得场上除自身以外所有符合条件的魔法·陷阱卡，作为操作信息的目标集合。
	local sg=Duel.GetMatchingGroup(c42703248.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 将本次连锁的操作信息设置为：回手牌类别，目标为已取得的卡片集合，数量为集合卡数。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：取得除去发动卡（若仍与效果相关）以外场上所有符合条件的魔法·陷阱卡，并将其送入持有者手卡。
function c42703248.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新取得场上除发动效果的卡以外（若该卡仍与效果相关）所有符合条件的魔法·陷阱卡。
	local sg=Duel.GetMatchingGroup(c42703248.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将取得的卡片以效果原因送回其持有者的手卡。
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
