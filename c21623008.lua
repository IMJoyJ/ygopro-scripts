--閃刀術式－ベクタードブラスト
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。从双方卡组上面把2张卡送去墓地。那之后，自己墓地有魔法卡3张以上存在的场合，可以让额外怪兽区域的对方怪兽全部回到持有者卡组。
function c21623008.initial_effect(c)
	-- ①效果：自己的主要怪兽区域没有怪兽存在的场合才能发动。从双方卡组上面把2张卡送去墓地。那之后，自己墓地有魔法卡3张以上存在的场合，可以让额外怪兽区域的对方怪兽全部回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c21623008.condition)
	e1:SetTarget(c21623008.target)
	e1:SetOperation(c21623008.operation)
	c:RegisterEffect(e1)
end
-- 筛选位于主要怪兽区域的卡（序号为0-4），用于判断自己主要怪兽区域是否有怪兽。
function c21623008.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件：自己主要怪兽区域没有怪兽存在时才能发动。
function c21623008.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 不存在满足条件（序号小于5）的卡，即自己主要怪兽区域没有怪兽。
	return not Duel.IsExistingMatchingCard(c21623008.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的处理：确认双方玩家都能从卡组顶端把2张卡送去墓地；登记将双方卡组顶2张送去墓地的操作信息；若自己墓地有3张以上魔法卡，则追加返回卡组分类。
function c21623008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法检查：双方玩家是否都能把卡组顶端2张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	-- 登记本次效果将把双方玩家卡组顶各2张卡送去墓地（不取对象，所以目标为0，数量为2，玩家为双方）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,PLAYER_ALL,2)
	-- 检查自己墓地是否有3张以上魔法卡，以决定是否在操作信息中加入返回卡组分类。
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		e:SetCategory(CATEGORY_DECKDES+CATEGORY_TOEXTRA)
	end
end
-- 筛选额外怪兽区域（序号≥5）中对方控制的、且能够返回卡组的怪兽。
function c21623008.filter(c,tp)
	return c:GetSequence()>=5 and c:IsControler(1-tp) and c:IsAbleToDeck()
end
-- 效果处理：从双方卡组顶各取2张卡合并后送去墓地；若成功送去墓地且这些卡中有卡进入墓地、自己墓地有3张以上魔法卡、对方额外怪兽区存在可返回卡组的怪兽，并且玩家选择是，则将这些怪兽弹回持有者卡组并洗牌。
function c21623008.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得己方卡组最上方的2张卡。
	local g1=Duel.GetDecktopGroup(tp,2)
	-- 取得对方卡组最上方的2张卡。
	local g2=Duel.GetDecktopGroup(1-tp,2)
	g1:Merge(g2)
	-- 关闭从卡组取卡后的自动洗牌检测，因为这里只是把卡组顶的卡送去墓地。
	Duel.DisableShuffleCheck()
	-- 将合并后的4张卡送去墓地；若实际成功送去墓地则继续后续判断。
	if Duel.SendtoGrave(g1,REASON_EFFECT)~=0
		and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 效果处理时再次确认自己墓地有3张以上魔法卡，满足追加返回卡组的条件。
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
		-- 检查对方场上额外怪兽区域是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c21623008.filter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 让己方玩家选择是否让额外怪兽区域的对方怪兽回到持有者卡组。
		and Duel.SelectYesNo(tp,aux.Stringid(21623008,0)) then  --"是否让额外怪兽区域的对方怪兽回到卡组？"
		-- 取得对方额外怪兽区域中所有符合条件的怪兽，用于返回卡组。
		local g=Duel.GetMatchingGroup(c21623008.filter,tp,0,LOCATION_MZONE,nil,tp)
		-- 重新启用洗牌检查，因为接下来要把卡弹回卡组并洗牌。
		Duel.DisableShuffleCheck(false)
		-- 将选中的对方额外怪兽全部弹回持有者卡组并洗切卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
