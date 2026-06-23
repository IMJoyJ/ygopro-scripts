--GMX Chairman Kimridge
-- 效果：
-- 可以把手卡的这张卡给对方观看：从自己的卡组·墓地把1张「GMX应用试验55号」加入手卡，这张卡回到卡组。
-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己墓地的「GMX」卡或者恐龙族怪兽合计2张为对象；那些卡用喜欢的顺序回到卡组上面，那之后，可以把对方场上1只表侧攻击表示怪兽破坏。
-- 「GMX理事长 基默里奇」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 记录卡片效果中记载了「GMX应用试验55号」的卡名
	aux.AddCodeList(c,18795635)
	-- 可以把手卡的这张卡给对方观看：从自己的卡组·墓地把1张「GMX应用试验55号」加入手卡，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己墓地的「GMX」卡或者恐龙族怪兽合计2张为对象；那些卡用喜欢的顺序回到卡组上面，那之后，可以把对方场上1只表侧攻击表示怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 效果1的发动代价：确认手牌的这张卡未处于公开状态
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：卡名为「GMX应用试验55号」且能加入手牌的卡
function s.thfilter(c)
	return c:IsCode(18795635) and c:IsAbleToHand()
end
-- 效果1的发动准备：检查卡组或墓地是否存在「GMX应用试验55号」且自身能回到卡组，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的卡组或墓地是否存在可以加入手牌的「GMX应用试验55号」，且手牌的这张卡可以回到卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	-- 设置连锁操作信息：从卡组或墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置连锁操作信息：将这张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果1的效果处理：从卡组或墓地将1张「GMX应用试验55号」加入手牌，之后将这张卡回到卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地选择1张满足条件的卡（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将这张卡送回卡组并洗牌
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 效果2的发动条件：这张卡是由怪兽的效果特殊召唤成功
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件：自己墓地的「GMX」卡或恐龙族怪兽，且能回到卡组
function s.tdfilter(c,e)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR)) and c:IsAbleToDeck()
end
-- 效果2的发动准备：选择自己墓地合计2张「GMX」卡或恐龙族怪兽作为对象，并设置操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在合计2张满足条件的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择墓地合计2张满足条件的卡作为效果对象
	local tg=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置连锁操作信息：将选中的对象卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
-- 效果2的效果处理：将作为对象的卡用喜欢的顺序回到卡组最上面，之后可以破坏对方场上1只表侧攻击表示怪兽
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()==0 then return end
	-- 将对象卡片送回卡组最上方，若没有卡成功回到卡组则处理结束
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 计算实际回到卡组（不含额外卡组）的卡片数量
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	-- 如果有卡回到卡组，让玩家用喜欢的顺序对卡组最上方的这些卡进行排序
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 检查对方场上是否存在表侧攻击表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
		-- 询问玩家是否选择发动破坏怪兽的效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择对方场上1只表侧攻击表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_ATTACK)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续的破坏处理与回到卡组不视为同时处理
			Duel.BreakEffect()
			-- 显式提示被选择破坏的怪兽
			Duel.HintSelection(g)
			-- 将选择的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
