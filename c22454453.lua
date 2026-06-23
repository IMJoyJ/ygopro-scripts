--謙虚な瓶
-- 效果：
-- ①：自己选1张手卡回到卡组最上面或者最下面。
function c22454453.initial_effect(c)
	-- 效果定义：将卡牌效果注册为发动时点，可自由连锁，设置为回卡组类别，设置提示时点为怪兽召唤或结束阶段
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c22454453.target)
	e1:SetOperation(c22454453.activate)
	c:RegisterEffect(e1)
end
-- 效果目标设定：检查自己手牌中是否存在可送回卡组的卡，若存在则设置操作信息为回卡组
function c22454453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：检查是否满足效果发动条件，即自己手牌中至少有一张可送回卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置操作信息：设定本次连锁处理的类别为回卡组，目标为1张手牌
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果发动处理：提示玩家选择要送回卡组的手牌，并根据卡组情况决定送回卡组顶端或底端
function c22454453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：向玩家发送提示信息，提示其选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择卡牌：从玩家手牌中选择1张可送回卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 判断卡组是否为空：检查玩家卡组中是否有卡
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
			-- 送回卡组底端：若卡组为空，则将选中的卡送回卡组底端
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		else
			-- 选择送回位置：提示玩家选择将卡送回卡组顶端或底端
			local opt=Duel.SelectOption(tp,aux.Stringid(22454453,0),aux.Stringid(22454453,1))  --"卡组最上面/卡组最下面"
			if opt==0 then
				-- 送回卡组顶端：将选中的卡送回卡组顶端
				Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 送回卡组底端：将选中的卡送回卡组底端
				Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
