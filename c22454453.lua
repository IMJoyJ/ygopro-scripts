--謙虚な瓶
-- 效果：
-- ①：自己选1张手卡回到卡组最上面或者最下面。
function c22454453.initial_effect(c)
	-- ①：自己选1张手卡回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c22454453.target)
	e1:SetOperation(c22454453.activate)
	c:RegisterEffect(e1)
end
-- 发动效果的目标函数：判定“谦虚之瓶”能否发动，并登记效果处理时将手牌返回卡组的操作信息。
function c22454453.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查自己手牌中是否存在至少1张能返回卡组的卡（且不是本卡本身），满足才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置操作信息：向系统登记本次连锁会把1张手牌返回卡组，目标区域为手牌区。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：选择自己手牌中的1张卡，按玩家选择的顺序（卡组最上面或最下面）放回卡组。
function c22454453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要返回卡组的卡”，引导玩家选择手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己手牌中选择1张能够返回卡组的卡（若不满足则不会进入此处理）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 检查自己的卡组张数是否为0；若为0则“最上面”和“最下面”没有区别，不再询问放置位置。
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
			-- 将选择的卡返回持有者的卡组最下面（卡组为空时采用的默认放置方式）。
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		else
			-- 让玩家在“卡组最上面”和“卡组最下面”两个选项中做出选择。
			local opt=Duel.SelectOption(tp,aux.Stringid(22454453,0),aux.Stringid(22454453,1))  --"卡组最上面/卡组最下面"
			if opt==0 then
				-- 将选择的卡返回持有者的卡组最上面。
				Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将选择的卡返回持有者的卡组最下面。
				Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
