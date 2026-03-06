--ヤドカリュー
-- 效果：
-- 这张卡的表示形式从攻击表示变成表侧守备表示时，可以从自己手卡把任意数量的卡回到卡组最下面。
function c29380133.initial_effect(c)
	-- 诱发选发效果，表示形式变更时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29380133,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c29380133.condition)
	e1:SetTarget(c29380133.target)
	e1:SetOperation(c29380133.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡的表示形式从攻击表示变成表侧守备表示时
function c29380133.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_ATTACK) and e:GetHandler():IsPosition(POS_DEFENSE)
end
-- 效果处理准备：检查自己手卡是否存在可送入卡组的卡
function c29380133.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张可送入卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理信息：将目标设为手卡中任意数量的卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理流程：选择并送入卡组最底端，然后将选中的卡按顺序移至卡组最底端
function c29380133.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择手卡中任意数量（1~99张）可送入卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,99,nil)
	-- 将选中的卡送入卡组最顶端
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	if ct==0 then return end
	-- 对玩家卡组最上方的卡进行排序
	Duel.SortDecktop(tp,tp,ct)
	for i=1,ct do
		-- 获取玩家卡组最上方的1张卡
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将卡移至卡组最底端
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
