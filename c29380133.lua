--ヤドカリュー
-- 效果：
-- 这张卡的表示形式从攻击表示变成表侧守备表示时，可以从自己手卡把任意数量的卡回到卡组最下面。
function c29380133.initial_effect(c)
	-- 这张卡的表示形式从攻击表示变成表侧守备表示时，可以从自己手卡把任意数量的卡回到卡组最下面。
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
-- 判定触发条件：这张卡的表示形式变化前是攻击表示，变化后是表侧守备表示时才满足发动条件。
function c29380133.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_ATTACK) and e:GetHandler():IsPosition(POS_DEFENSE)
end
-- 效果发动前的合法性检查和设置操作信息：先确认满足发动条件，再向系统声明本效果涉及将手卡返回卡组的处理。
function c29380133.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己手卡中是否存在至少1张可以返回卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) end
	-- 设置本连锁的操作信息，将效果分类标记为回卡组，并声明对象区域为自己手卡，用于后续相关效果的检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：发动者从自己手卡选择任意数量可以返回卡组的卡，将其按所选顺序全部放回卡组最下方。
function c29380133.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动者弹出选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让发动者从自己手卡中选择1～99张（即任意数量）可以返回卡组的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,99,nil)
	-- 将选中的卡以效果原因送回到持有者卡组最顶端（作为临时放置，便于后续排序），并返回实际送回的数量ct。
	local ct=Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	if ct==0 then return end
	-- 若ct大于0，让发动者对自己卡组最上方ct张卡进行排序，使卡片的排列顺序决定最终放回卡组最下面的顺序。
	Duel.SortDecktop(tp,tp,ct)
	for i=1,ct do
		-- 取得当前卡组最上方的1张卡。
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将这张卡从卡组最上方移动到卡组最底端；循环ct次后，之前选中的所有卡就按排序后的顺序依次被放回卡组最下面。
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
