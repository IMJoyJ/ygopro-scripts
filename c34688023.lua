--エッジインプ・ソウ
-- 效果：
-- 「锋利小鬼·锯子」的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，把手卡1只「毛绒动物」怪兽送去墓地才能发动。自己从卡组抽2张，那之后，选1张手卡回到卡组最上面或者最下面。
function c34688023.initial_effect(c)
	-- 「锋利小鬼·锯子」的效果1回合只能使用1次。①：这张卡召唤成功时，把手卡1只「毛绒动物」怪兽送去墓地才能发动。自己从卡组抽2张，那之后，选1张手卡回到卡组最上面或者最下面。
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
-- 定义过滤条件：持有「毛绒动物」字段、是怪兽且可以作为代价送去墓地。
function c34688023.cfilter(c)
	return c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 作为发动代价，从手卡丢弃1只满足条件的「毛绒动物」怪兽。
function c34688023.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1张可供丢弃的「毛绒动物」怪兽作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c34688023.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家从手卡选择1张「毛绒动物」怪兽作为代价丢弃。
	Duel.DiscardHand(tp,c34688023.cfilter,1,1,REASON_COST)
end
-- 设定效果对象为自己，抽卡数量为2，并将本次操作信息登记为抽卡效果。
function c34688023.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将效果处理时的对象玩家设为自己。
	Duel.SetTargetPlayer(tp)
	-- 将效果处理时的对象参数设为2（抽卡数量）。
	Duel.SetTargetParam(2)
	-- 登记本次操作信息：效果类别为抽卡，预计处理时让自己抽2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理时先抽2张，若成功则再选择1张手卡放回卡组最上面或最下面。
function c34688023.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此前设置的对象玩家和抽卡参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让自己抽2张；若实际抽卡数不足2张，则不再进行后续返回卡组的处理。
	if Duel.Draw(p,d,REASON_EFFECT)<2 then return end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己的手卡中选择1张可以返回卡组的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果，使之后返回卡组的处理视为不同时处理，避免错时点。
		Duel.BreakEffect()
		-- 让玩家选择将选中的卡返回卡组最上面还是最下面，选择0代表返回最上面。
		if Duel.SelectOption(tp,aux.Stringid(34688023,1),aux.Stringid(34688023,2))==0 then  --"回卡组最上面/回卡组最下面"
			-- 将选中的卡返回卡组最上面。
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将选中的卡返回卡组最下面。
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
