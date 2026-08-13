--黒・魔・導
-- 效果：
-- ①：自己场上有「黑魔术师」存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
function c2314238.initial_effect(c)
	-- 为这张卡注册「黑魔术师」的关联卡名（卡号46986414），用于记录卡面文字中提及的卡名。
	aux.AddCodeList(c,46986414)
	-- 对应效果原文：①：自己场上有「黑魔术师」存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c2314238.condition)
	e1:SetTarget(c2314238.target)
	e1:SetOperation(c2314238.activate)
	c:RegisterEffect(e1)
end
-- 定义cfilter：判定一张卡是否为表侧表示且卡号为46986414（「黑魔术师」），用于检查发动条件中的“自己场上有「黑魔术师」存在”。
function c2314238.cfilter(c)
	return c:IsFaceup() and c:IsCode(46986414)
end
-- 定义condition：效果的发动条件，检查自己场上是否存在至少1张满足cfilter的卡（即表侧表示的黑魔术师）。
function c2314238.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp的场上（LOCATION_ONFIELD）是否存在至少1张表侧表示的「黑魔术师」（cfilter），以此作为发动条件。
	return Duel.IsExistingMatchingCard(c2314238.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义filter：判定一张卡是否为魔法·陷阱卡（魔法卡或陷阱卡），用于筛选对方场上要破坏的对象。
function c2314238.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义target：效果发动时的目标检查和操作信息设置。在发动合法性检查时确认对方场上有魔法·陷阱卡；若合法，则获取对方场上所有魔法·陷阱卡并设置破坏操作信息。
function c2314238.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk==0（发动合法性检查）时，确认对方场上是否存在至少1张魔法·陷阱卡（排除本卡），否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2314238.filter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上全部满足filter的魔法·陷阱卡（排除本卡），作为准备破坏的卡片集合。
	local sg=Duel.GetMatchingGroup(c2314238.filter,tp,0,LOCATION_ONFIELD,c)
	-- 将本次效果处理信息设为破坏sg中的所有卡，数量为sg:GetCount()，分类为CATEGORY_DESTROY，用于连锁/时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义activate：效果处理函数。实际执行时再次获取对方场上全部魔法·陷阱卡并全部破坏。
function c2314238.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，获取对方场上所有魔法·陷阱卡，并通过aux.ExceptThisCard(e)将效果发动者（本卡自身）排除在外，得到待破坏的卡组。
	local sg=Duel.GetMatchingGroup(c2314238.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将sg中的卡片全部以效果破坏（REASON_EFFECT）送入墓地，完成“对方场上的魔法·陷阱卡全部破坏”。
	Duel.Destroy(sg,REASON_EFFECT)
end
