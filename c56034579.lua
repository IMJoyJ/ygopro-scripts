--GMX主任教授キンリッジ
-- 效果：
-- 可以把手卡的这张卡给对方观看：从自己的卡组·墓地把1张「GMX应用试验55号」加入手卡，这张卡回到卡组。
-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己墓地的「GMX」卡或者恐龙族怪兽合计2张为对象；那些卡用喜欢的顺序回到卡组上面，那之后，可以把对方场上1只表侧攻击表示怪兽破坏。
-- 「GMX理事长 基默里奇」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡片、手牌展示检索并自身洗回卡组效果、以及怪兽效果特召成功时回收卡组顶并破坏怪兽效果
function s.initial_effect(c)
	-- 注册卡片记述列表：记述「GMX应用试验55号」
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
-- 手牌检索效果Cost：把手卡的这张卡给对方观看
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤条件：卡号为18795635（GMX应用试验55号）且可加入手牌
function s.thfilter(c)
	return c:IsCode(18795635) and c:IsAbleToHand()
end
-- 手牌检索效果准备：设置从卡组·墓地检索及自身返回卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：卡组/墓地存在目标卡且自身能回到卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	-- 设置连锁操作信息：从卡组/墓地把1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置连锁操作信息：将自身1张卡洗回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 手牌检索效果处理：从卡组/墓地检索1张「GMX应用试验55号」加入手卡，并将自身洗回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组/墓地选择1张「GMX应用试验55号」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将自身洗回卡组
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 特召诱发条件：必须是被怪兽效果特殊召唤
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 墓地回收过滤条件：「GMX」卡或恐龙族怪兽且可回到卡组
function s.tdfilter(c,e)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR)) and c:IsAbleToDeck()
end
-- 特召诱发准备：选择墓地2张目标卡并设置返回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动条件检查：墓地是否存在至少2张符合条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组顶的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地2张满足条件的卡作为对象
	local tg=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置连锁操作信息：将2张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
-- 特召诱发处理：将墓地2张卡放回卡组顶并按喜好排列，随后可破坏对方1只表侧攻击怪兽
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍关联且不受墓谷影响的目标卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()==0 then return end
	-- 将目标卡放回卡组顶，若失败则终止后续处理
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 统计实际返回卡组的卡片数量
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	-- 让玩家自行决定返回卡组顶卡片的排列顺序
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 检查对方场上是否存在表侧攻击表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
		-- 询问玩家是否选择破坏对方怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1只表侧攻击表示怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_ATTACK)
		if g:GetCount()>0 then
			-- 连接效果块（分隔返回卡组与破坏怪兽的操作）
			Duel.BreakEffect()
			-- 高亮显示要破坏的怪兽
			Duel.HintSelection(g)
			-- 破坏选中的怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
