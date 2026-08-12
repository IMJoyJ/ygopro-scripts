--閃刀術式－ベクタードブラスト
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合才能发动。从双方卡组上面把2张卡送去墓地。那之后，自己墓地有魔法卡3张以上存在的场合，可以让额外怪兽区域的对方怪兽全部回到持有者卡组。
function c21623008.initial_effect(c)
	-- 效果初始化，设置效果类型为发动时点，条件为己方主要怪兽区域没有怪兽存在，目标为双方卡组最上方各2张卡送去墓地，操作为后续处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c21623008.condition)
	e1:SetTarget(c21623008.target)
	e1:SetOperation(c21623008.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断怪兽是否在主要怪兽区域（序号小于5）
function c21623008.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件函数，判断己方主要怪兽区域是否没有怪兽存在
function c21623008.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区域是否没有怪兽存在
	return not Duel.IsExistingMatchingCard(c21623008.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，检查双方是否可以各从卡组顶部送去2张卡到墓地，并根据己方墓地魔法卡数量决定是否添加将怪兽送回卡组的分类
function c21623008.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方和对方是否可以各从卡组顶部送去2张卡到墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) and Duel.IsPlayerCanDiscardDeck(1-tp,2) end
	-- 设置操作信息，表示将双方卡组最上方各2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,PLAYER_ALL,2)
	-- 检查己方墓地是否至少有3张魔法卡
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		e:SetCategory(CATEGORY_DECKDES+CATEGORY_TOEXTRA)
	end
end
-- 过滤函数，用于判断对方额外怪兽区域的怪兽是否可以送回卡组
function c21623008.filter(c,tp)
	return c:GetSequence()>=5 and c:IsControler(1-tp) and c:IsAbleToDeck()
end
-- 效果处理函数，执行将双方卡组最上方各2张卡送去墓地的操作，并在满足条件时询问是否将对方额外怪兽区域的怪兽送回卡组
function c21623008.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方卡组最上方2张卡
	local g1=Duel.GetDecktopGroup(tp,2)
	-- 获取对方卡组最上方2张卡
	local g2=Duel.GetDecktopGroup(1-tp,2)
	g1:Merge(g2)
	-- 禁用洗牌检查，防止在送卡到墓地后自动洗牌
	Duel.DisableShuffleCheck()
	-- 将获取的卡组最上方卡送去墓地
	if Duel.SendtoGrave(g1,REASON_EFFECT)~=0
		and g1:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 检查己方墓地是否至少有3张魔法卡
		and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
		-- 检查对方主要怪兽区域是否存在可送回卡组的怪兽
		and Duel.IsExistingMatchingCard(c21623008.filter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 询问玩家是否让对方额外怪兽区域的怪兽回到卡组
		and Duel.SelectYesNo(tp,aux.Stringid(21623008,0)) then  --"是否让额外怪兽区域的对方怪兽回到卡组？"
		-- 获取对方主要怪兽区域中可送回卡组的怪兽
		local g=Duel.GetMatchingGroup(c21623008.filter,tp,0,LOCATION_MZONE,nil,tp)
		-- 重新启用洗牌检查
		Duel.DisableShuffleCheck(false)
		-- 将选中的怪兽送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
