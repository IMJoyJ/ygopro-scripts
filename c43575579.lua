--アフター・グロー
-- 效果：
-- 这个卡名的卡在决斗中只能发动1张。
-- ①：从自己的手卡·卡组·墓地以及自己场上的表侧表示的卡之中把包含这张卡的「残照」全部除外。那之后，从除外的自己的卡之中选1张「残照」加入卡组。下次的自己抽卡阶段，通常抽卡的卡给双方确认。那是「残照」的场合，给与对方4000伤害。
function c43575579.initial_effect(c)
	-- ①：从自己的手卡·卡组·墓地以及自己场上的表侧表示的卡之中把包含这张卡的「残照」全部除外。那之后，从除外的自己的卡之中选1张「残照」加入卡组。下次的自己抽卡阶段，通常抽卡的卡给双方确认。那是「残照」的场合，给与对方4000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,43575579+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43575579.target)
	e1:SetOperation(c43575579.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以除外的「残照」卡片
function c43575579.rmfilter(c)
	return c:IsCode(43575579) and c:IsAbleToRemove() and (c:IsFaceup() or not c:IsOnField())
end
-- 过滤函数，用于筛选可以加入卡组的「残照」卡片
function c43575579.tdfilter(c)
	return c:IsCode(43575579) and c:IsAbleToDeck() and c:IsFaceup()
end
-- 效果的处理目标函数，设置除外和加入卡组的卡
function c43575579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足除外条件的「残照」卡片组
	local g=Duel.GetMatchingGroup(c43575579.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,nil)
	g:AddCard(e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK)
	-- 设置加入卡组效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
-- 效果的处理函数，执行除外和加入卡组操作，并注册抽卡时的伤害效果
function c43575579.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取满足除外条件的「残照」卡片组
	local g=Duel.GetMatchingGroup(c43575579.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,nil)
	-- 执行除外操作，将卡片除外
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 提示玩家选择要返回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择要返回卡组的卡片
		local tg=Duel.SelectMatchingCard(tp,c43575579.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if tg:GetCount()>0 then
			-- 将选中的卡片返回卡组
			Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	-- 注册抽卡时的伤害效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(c43575579.damcon)
	e1:SetOperation(c43575579.damop)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
	-- 将伤害效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 伤害效果的触发条件函数，判断是否为规则抽卡
function c43575579.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==e:GetOwnerPlayer() and r==REASON_RULE
end
-- 伤害效果的处理函数，确认抽卡并造成伤害
function c43575579.damop(e,tp,eg,ep,ev,re,r,rp)
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if hg:GetCount()==0 then return end
	-- 确认对方抽卡的卡片
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(Card.IsCode,nil,43575579)
	if dg:GetCount()>0 then
		-- 提示对方宣言了「残照」卡片
		Duel.Hint(HINT_CARD,0,43575579)
		-- 给与对方4000伤害
		Duel.Damage(1-ep,4000,REASON_EFFECT)
	end
	-- 洗切自己的手牌
	Duel.ShuffleHand(ep)
end
