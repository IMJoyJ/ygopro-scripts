--ダークアイ・ナイトメア
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己墓地最多3张陷阱卡除外才能发动。除外数量的以下效果适用。
-- ●1张：自己从卡组抽1张，那之后选1张手卡回到卡组最上面。
-- ●2张：自己从卡组抽1张。
-- ●3张：自己从卡组抽2张，那之后选1张手卡丢弃。
-- ②：1回合1次，这张卡被战斗破坏的场合，可以作为代替把自己墓地1张陷阱卡除外。
function c88685329.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把自己墓地最多3张陷阱卡除外才能发动。除外数量的以下效果适用。●1张：自己从卡组抽1张，那之后选1张手卡回到卡组最上面。●2张：自己从卡组抽1张。●3张：自己从卡组抽2张，那之后选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,88685329)
	e1:SetCost(c88685329.drcost)
	e1:SetTarget(c88685329.drtg)
	e1:SetOperation(c88685329.drop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡被战斗破坏的场合，可以作为代替把自己墓地1张陷阱卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c88685329.reptg)
	c:RegisterEffect(e2)
end
-- 过滤条件：墓地的陷阱卡且可以作为代价除外
function c88685329.drfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价：除外自己墓地最多3张陷阱卡，并记录除外的数量
function c88685329.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张可以作为代价除外的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c88685329.drfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local ct=2
	-- 如果玩家可以抽2张卡，则最大除外数量设为3，否则最大除外数量设为2
	if Duel.IsPlayerCanDraw(tp,2) then ct=3 end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1到ct张满足条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c88685329.drfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的卡作为代价表侧表示除外，并将实际除外的数量作为Label记录
	e:SetLabel(Duel.Remove(g,POS_FACEUP,REASON_COST))
end
-- ①效果的目标检查与操作信息设置：根据除外的卡片数量（Label值）设置对应的效果分类和操作信息
function c88685329.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽至少1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local label=e:GetLabel()
	if label==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
		-- 设置操作信息：玩家抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		-- 设置操作信息：将1张手牌送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	elseif label==2 then
		e:SetCategory(CATEGORY_DRAW)
		-- 设置操作信息：玩家抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif label==3 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		-- 设置操作信息：玩家抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		-- 设置操作信息：玩家丢弃1张手牌
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	end
end
-- ①效果的处理：根据除外的卡片数量（Label值）执行对应的抽卡及后续手牌处理效果
function c88685329.drop(e,tp,eg,ep,ev,re,r,rp)
	local label=e:GetLabel()
	if label==1 then
		-- 如果成功由效果抽了1张卡
		if Duel.Draw(tp,1,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续处理不与抽卡同时进行（造成错时点）
			Duel.BreakEffect()
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 让玩家选择1张可以回到卡组的手牌
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			-- 将选中的手牌送回卡组最上面
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	elseif label==2 then
		-- 玩家由效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	elseif label==3 then
		-- 如果成功由效果抽了2张卡
		if Duel.Draw(tp,2,REASON_EFFECT)~=0 then
			-- 中断当前效果处理，使后续处理不与抽卡同时进行（造成错时点）
			Duel.BreakEffect()
			-- 洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 让玩家选择1张手牌
			local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
			-- 将选中的手牌作为效果丢弃送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 代替破坏的过滤条件：墓地的陷阱卡且可以被除外
function c88685329.repfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemove()
end
-- ②效果的代替破坏处理：当此卡被战斗破坏时，可以除外墓地1张陷阱卡代替
function c88685329.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否因战斗被破坏，且自己墓地是否存在可以除外的陷阱卡
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE) and Duel.IsExistingMatchingCard(c88685329.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择自己墓地1张满足条件的陷阱卡
		local g=Duel.SelectMatchingCard(tp,c88685329.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的卡作为代替破坏的效果表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
