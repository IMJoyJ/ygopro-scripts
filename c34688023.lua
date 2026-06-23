--エッジインプ・ソウ
-- 效果：
-- 「锋利小鬼·锯子」的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，把手卡1只「毛绒动物」怪兽送去墓地才能发动。自己从卡组抽2张，那之后，选1张手卡回到卡组最上面或者最下面。
function c34688023.initial_effect(c)
	-- ①：这张卡召唤成功时，把手卡1只「毛绒动物」怪兽送去墓地才能发动。自己从卡组抽2张，那之后，选1张手卡回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34688023,0))  --"抽2张卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,34688023)
	e1:SetCost(c34688023.cost)
	e1:SetTarget(c34688023.target)
	e1:SetOperation(c34688023.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中满足「毛绒动物」种族、怪兽类型且能作为墓地代价的卡片。
function c34688023.cfilter(c)
	return c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 效果发动的费用处理，检查手卡是否存在满足条件的卡片并将其丢弃至墓地。
function c34688023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张满足条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c34688023.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张满足条件的卡片作为发动费用。
	Duel.DiscardHand(tp,c34688023.cfilter,1,1,REASON_COST)
end
-- 效果发动时的处理目标设置，确认玩家可以抽2张卡并设置连锁操作信息。
function c34688023.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁效果的目标玩家为当前处理效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁效果的目标参数为2（表示抽2张卡）。
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理操作，执行抽卡并选择将手卡返回卡组顶端或底端。
function c34688023.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，若实际抽卡数不足2则中断效果处理。
	if Duel.Draw(p,d,REASON_EFFECT)<2 then return end
	-- 提示玩家选择将手卡返回卡组顶端或底端。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择手卡中1张可送回卡组的卡片。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续处理视为错时点。
		Duel.BreakEffect()
		-- 让玩家选择将卡片送回卡组顶端或底端。
		if Duel.SelectOption(tp,aux.Stringid(34688023,1),aux.Stringid(34688023,2))==0 then  --"回卡组最上面/回卡组最下面"
			-- 将选中的卡片送回卡组顶端。
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将选中的卡片送回卡组底端。
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
