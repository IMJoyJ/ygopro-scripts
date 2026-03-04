--レクリスパワー
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c11596936.initial_effect(c)
	-- 为卡片注册关联卡片代码，标明该卡效果文本中存在「核成兽的钢核」
	aux.AddCodeList(c,36623431)
	-- 把手卡1张「核成兽的钢核」给对方观看发动。对方场上盖放的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c11596936.cost)
	e1:SetTarget(c11596936.target)
	e1:SetOperation(c11596936.activate)
	c:RegisterEffect(e1)
end
-- 检查手卡中是否存在未公开的「核成兽的钢核」
function c11596936.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 支付效果代价，确认手卡中的「核成兽的钢核」
function c11596936.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足支付代价的条件，即手卡中存在未公开的「核成兽的钢核」
	if chk==0 then return Duel.IsExistingMatchingCard(c11596936.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 选择手卡中一张未公开的「核成兽的钢核」
	local g=Duel.SelectMatchingCard(tp,c11596936.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示所选的「核成兽的钢核」
	Duel.ConfirmCards(1-tp,g)
	-- 将发动者手牌洗牌
	Duel.ShuffleHand(tp)
end
-- 筛选对方场上盖放的魔法·陷阱卡
function c11596936.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果发动时的目标
function c11596936.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即对方场上存在盖放的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11596936.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有盖放的魔法·陷阱卡
	local sg=Duel.GetMatchingGroup(c11596936.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，标明将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 发动效果，执行破坏操作
function c11596936.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有盖放的魔法·陷阱卡，排除本卡
	local sg=Duel.GetMatchingGroup(c11596936.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果原因破坏目标魔法·陷阱卡
	Duel.Destroy(sg,REASON_EFFECT)
end
