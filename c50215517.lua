--クリムゾン・ヘル・セキュア
-- 效果：
-- 自己场上有「红莲魔龙」表侧表示存在的场合才能发动。对方场上存在的魔法·陷阱卡全部破坏。
function c50215517.initial_effect(c)
	-- 记录此卡关联「红莲魔龙」的卡片密码
	aux.AddCodeList(c,70902743)
	-- 自己场上有「红莲魔龙」表侧表示存在的场合才能发动。对方场上存在的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c50215517.condition)
	e1:SetTarget(c50215517.target)
	e1:SetOperation(c50215517.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为表侧表示的「红莲魔龙」
function c50215517.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 判断自身场上是否存在表侧表示的「红莲魔龙」
function c50215517.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「红莲魔龙」
	return Duel.IsExistingMatchingCard(c50215517.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数，检查是否为魔法或陷阱卡
function c50215517.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果处理时的目标为对方场上的魔法·陷阱卡，并设定破坏类别
function c50215517.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在处理效果时对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c50215517.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有满足条件的魔法·陷阱卡组成的组
	local sg=Duel.GetMatchingGroup(c50215517.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置当前连锁操作信息为破坏效果，目标为上述魔法·陷阱卡组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行效果的处理函数，将对方场上的魔法·陷阱卡全部破坏
function c50215517.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足条件的魔法·陷阱卡组成的组（排除此卡自身）
	local sg=Duel.GetMatchingGroup(c50215517.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因将目标卡组全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
