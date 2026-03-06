--黒・魔・導
-- 效果：
-- ①：自己场上有「黑魔术师」存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
function c2314238.initial_effect(c)
	-- 记录此卡具有「黑魔术师」的卡片密码，用于效果条件判断
	aux.AddCodeList(c,46986414)
	-- ①：自己场上有「黑魔术师」存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c2314238.condition)
	e1:SetTarget(c2314238.target)
	e1:SetOperation(c2314238.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「黑魔术师」
function c2314238.cfilter(c)
	return c:IsFaceup() and c:IsCode(46986414)
end
-- 判断发动条件：自己场上有「黑魔术师」存在
function c2314238.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「黑魔术师」
	return Duel.IsExistingMatchingCard(c2314238.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：判断是否为魔法或陷阱卡
function c2314238.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果目标：检索对方场上所有魔法·陷阱卡并设置为破坏对象
function c2314238.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足发动条件：对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c2314238.filter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上所有满足条件的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c2314238.filter,tp,0,LOCATION_ONFIELD,c)
	-- 设置连锁操作信息：将检索到的魔法·陷阱卡设为破坏对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果发动时执行的操作：破坏对方场上所有魔法·陷阱卡
function c2314238.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的魔法·陷阱卡（排除此卡自身）
	local sg=Duel.GetMatchingGroup(c2314238.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将目标魔法·陷阱卡以效果原因进行破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
