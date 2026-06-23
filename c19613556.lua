--大嵐
-- 效果：
-- ①：场上的魔法·陷阱卡全部破坏。
function c19613556.initial_effect(c)
	-- ①：场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19613556.target)
	e1:SetOperation(c19613556.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡片是否为魔法卡或陷阱卡
function c19613556.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的发动时点处理函数，检查场上是否存在魔法·陷阱卡并设置破坏操作信息
function c19613556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c19613556.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有满足条件的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c19613556.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置连锁操作信息，指定将要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果发动时的处理函数，执行破坏效果
function c19613556.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的魔法·陷阱卡（排除自身）
	local sg=Duel.GetMatchingGroup(c19613556.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将目标卡片组以效果原因进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
