--ハーピィの羽根帚
-- 效果：
-- ①：对方场上的魔法·陷阱卡全部破坏。
function c18144506.initial_effect(c)
	-- ①：对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c18144506.target)
	e1:SetOperation(c18144506.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡片是否为魔法卡或陷阱卡
function c18144506.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的发动时点处理函数，检查对方场上是否存在魔法·陷阱卡并设置破坏操作信息
function c18144506.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足发动条件，即对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c18144506.filter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上所有满足条件的魔法·陷阱卡组成的集合
	local sg=Duel.GetMatchingGroup(c18144506.filter,tp,0,LOCATION_ONFIELD,c)
	-- 设置连锁操作信息，指定将要破坏的卡片集合及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果的发动处理函数，执行破坏效果
function c18144506.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的魔法·陷阱卡组成的集合（排除自身）
	local sg=Duel.GetMatchingGroup(c18144506.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将指定的卡片集合以效果原因进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
