--アフター・グロー
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：从自己的手卡·卡组·墓地以及自己场上的表侧表示的卡之中把包含这张卡的「残照」全部除外。那之后，从除外的自己的卡之中选1张「残照」加入卡组。下次的自己抽卡阶段，通常抽卡的卡给双方确认。那是「残照」的场合，给与对方4000伤害。
function c43575579.initial_effect(c)
	-- 这个卡名的卡在决斗中只能发动1张。①：从自己的手卡·卡组·墓地以及自己场上的表侧表示的卡之中把包含这张卡的「残照」全部除外。那之后，从除外的自己的卡之中选1张「残照」加入卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,43575579+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43575579.target)
	e1:SetOperation(c43575579.operation)
	c:RegisterEffect(e1)
end
-- 筛选可被除外的「残照」：卡号为43575579且可被除外，场上需表侧表示，手卡·卡组·墓地不限表侧。
function c43575579.rmfilter(c)
	return c:IsCode(43575579) and c:IsAbleToRemove() and (c:IsFaceup() or not c:IsOnField())
end
-- 筛选从除外区返回卡组的「残照」：卡号为43575579、可返回卡组且表侧表示。
function c43575579.tdfilter(c)
	return c:IsCode(43575579) and c:IsAbleToDeck() and c:IsFaceup()
end
-- 发动时判定：检索自己手卡·场上（表侧）·墓地·卡组中所有可除外的「残照」，并将本卡也加入其中，若存在则满足发动条件；同时登记除外和回卡组的操作信息。
function c43575579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从自己的手卡、场上、墓地、卡组中取满足rmfilter的「残照」集合（场上仅表侧卡）。
	local g=Duel.GetMatchingGroup(c43575579.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,nil)
	g:AddCard(e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 登记除外操作信息：将集合g中的卡作为可能被除外的对象，数量为g的卡数，来源为手卡·场上·墓地·卡组。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK)
	-- 登记回卡组操作信息：预计从除外区选1张「残照」返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：若本卡仍与效果关联则继续；重新获取当前应除外的「残照」并全部表侧除外；实际除外后从除外区选1张「残照」返回卡组；之后注册下次自己抽卡阶段的持续效果。
function c43575579.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 效果处理时重新获取当前应除外的「残照」集合，确保处理时卡片位置准确。
	local g=Duel.GetMatchingGroup(c43575579.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,nil)
	-- 将筛选出的「残照」全部以表侧表示除外，并判断是否至少除除了1张。
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 给出选择提示：请从除外区选择1张要返回卡组的「残照」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己的除外区选择1张满足tdfilter的「残照」作为返回卡组的对象。
		local tg=Duel.SelectMatchingCard(tp,c43575579.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if tg:GetCount()>0 then
			-- 将选中的「残照」送入其持有者的卡组，并按洗牌处理（返回卡组后洗牌）。
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	-- 下次的自己抽卡阶段，通常抽卡的卡给双方确认。那是「残照」的场合，给与对方4000伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c43575579.damcon)
	e1:SetOperation(c43575579.damop)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	-- 将该持续效果注册到决斗中，使其在下一次自己抽卡阶段的通常抽卡时触发。
	Duel.RegisterEffect(e1,tp)
end
-- 触发条件：抽卡者是本卡发动者，且该抽卡是规则上的通常抽卡。
function c43575579.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==e:GetOwnerPlayer() and r==REASON_RULE
end
-- 处理确认与伤害：取出本次通常抽卡抽到的卡，向对方确认；若其中有「残照」则展示并造成4000伤害；最后洗切抽卡者的手卡。
function c43575579.damop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 将本次通常抽卡抽到的卡给对方的玩家确认。
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(Card.IsCode,nil,43575579)
	if dg:GetCount()>0 then
		-- 展示卡号43575579（「残照」）的卡片动画，提示双方该卡被确认。
		Duel.Hint(HINT_CARD,0,43575579)
		-- 给对方玩家造成4000点效果伤害。
		Duel.Damage(1-ep,4000,REASON_EFFECT)
	end
	-- 洗切抽卡者的手卡，并重置手卡洗切检测状态。
	Duel.ShuffleHand(ep)
end
