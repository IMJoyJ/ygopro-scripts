--レクリスパワー
-- 效果：
-- 把手卡1张「核成兽的钢核」给对方观看发动。对方场上盖放的魔法·陷阱卡全部破坏。
function c11596936.initial_effect(c)
	-- 将该卡登记为记载着「核成兽的钢核」卡名的卡，以便相关卡名判定规则能识别。
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
-- 定义代价筛选函数：判断手牌中的卡是否为「核成兽的钢核」且当前处于非公开状态，满足条件的卡才能作为展示代价。
function c11596936.cfilter(c)
	return c:IsCode(36623431) and not c:IsPublic()
end
-- 定义代价执行函数：确认手牌存在可展示的「核成兽的钢核」后，从中选择1张展示给对方，然后洗切手牌，作为发动该卡所需支付的代价。
function c11596936.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查阶段（chk==0），确认手牌中是否存在至少1张满足条件的「核成兽的钢核」，以判断是否满足发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c11596936.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向当前玩家显示“请选择给对方确认的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让当前玩家从手牌中选出1张满足条件的「核成兽的钢核」，作为给对方确认的对象。
	local g=Duel.SelectMatchingCard(tp,c11596936.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选出的那张「核成兽的钢核」展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切当前玩家的手牌，防止因展示而暴露手牌顺序信息。
	Duel.ShuffleHand(tp)
end
-- 定义破坏目标筛选函数：判断卡片是否为里侧表示，且属于魔法·陷阱卡，用于选择对方场上要被破坏的盖放卡。
function c11596936.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果发动前的目标设定函数：确认对方场上是否存在至少1张里侧表示的魔法·陷阱卡；若存在，则获取所有此类卡的集合，并设置该破坏效果的操作信息，供连锁判定和后续处理使用。
function c11596936.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，确认对方场上是否存在里侧表示的魔法·陷阱卡，以判断该效果是否满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c11596936.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有里侧表示的魔法·陷阱卡，组成一个卡组集合（sg），用于设置操作信息。
	local sg=Duel.GetMatchingGroup(c11596936.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将本次处理的连锁操作信息设置为破坏效果：对象为对方的那些里侧魔法·陷阱卡，数量为sg:GetCount()，使其他卡的效果（如星尘龙、王家长眠之谷等）能据此正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义效果处理函数：在效果结算时重新获取对方场上的里侧魔法·陷阱卡，并将它们全部破坏。
function c11596936.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理阶段重新取得对方场上里侧表示的魔法·陷阱卡，并排除与当前效果存在联系的卡（通常是发动效果的这张卡自身），以避免误破坏自身。
	local sg=Duel.GetMatchingGroup(c11596936.filter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以“效果”为破坏原因，将这些里侧表示的魔法·陷阱卡全部破坏，即达成“对方场上盖放的魔法·陷阱卡全部破坏”的效果。
	Duel.Destroy(sg,REASON_EFFECT)
end
