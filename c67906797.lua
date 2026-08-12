--天地返し
-- 效果：
-- ①：自己卡组最下面的卡加入手卡。那之后，从自己卡组选1张卡在卡组最下面放置。
function c67906797.initial_effect(c)
	-- ①：自己卡组最下面的卡加入手卡。那之后，从自己卡组选1张卡在卡组最下面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c67906797.target)
	e1:SetOperation(c67906797.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：自己卡组的卡片数量在2张以上，且存在可以加入手卡的卡
function c67906797.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己卡组的卡片数量是否在2张以上（确保有卡加入手卡后卡组仍有卡可供选择并放置）
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
		-- 并且自己卡组中存在可以加入手卡的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将自己卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：将自己卡组最下方的卡加入手卡，之后洗牌，并从卡组选择1张卡放置在卡组最下方
function c67906797.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()==0 then return end
	local tc=g:GetMinGroup(Card.GetSequence):GetFirst()
	-- 使接下来的操作不触发系统的自动洗牌检测（防止加入手卡时自动洗牌导致卡组顺序改变）
	Duel.DisableShuffleCheck()
	tc:SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
	-- 如果成功将卡片加入手卡
	if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 如果此时自己卡组的卡片数量在1张以下，则不进行后续处理
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=1 then return end
		-- 中断当前效果处理，使后续的放置卡片操作与加入手卡不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要在卡组最下面放置的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(67906797,1))  --"请选择要在卡组最下面放置的卡"
		-- 从自己卡组选择任意1张卡
		local seg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
		local sec=seg:GetFirst()
		if sec then
			-- 洗切自己的卡组
			Duel.ShuffleDeck(tp)
			-- 将选择的卡移动到卡组最下方
			Duel.MoveSequence(sec,SEQ_DECKBOTTOM)
		end
	end
end
