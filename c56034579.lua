--GMX Chairman Kimridge
-- 效果：
-- 可以把手卡的这张卡给对方观看：从自己的卡组·墓地把1张「GMX应用试验55号」加入手卡，这张卡回到卡组。
-- 这张卡用怪兽的效果特殊召唤的场合：可以以自己墓地的「GMX」卡或者恐龙族怪兽合计2张为对象；那些卡用喜欢的顺序回到卡组上面，那之后，可以把对方场上1只表侧攻击表示怪兽破坏。
-- 「GMX理事长 基默里奇」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 注册卡片的初始效果：手卡发动的起动效果e1（检索并返回卡组）和特殊召唤成功时发动的诱发选发效果e2（墓地卡片返回卡组并破坏怪兽）
function s.initial_effect(c)
	-- 在卡片上记录其效果中记载了「GMX应用试验55号」（卡号：18795635）
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
-- 效果1发动的Cost，检查手卡中的这张卡是否未被公开
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件，筛选卡组或墓地中卡号为18795635的「GMX应用试验55号」且可加入手卡的卡片
function s.thfilter(c)
	return c:IsCode(18795635) and c:IsAbleToHand()
end
-- 效果1的Target，检查可发动性并设置将卡片加入手卡与此卡自身返回卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方卡组或墓地是否存在可加入手卡的「GMX应用试验55号」，且手卡中的此卡是否能返回卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	-- 设置操作信息，即预计会从己方的卡组或墓地将1张卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息，即预计会将此卡自身返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 效果1的Operation，将卡组或墓地的1张「GMX应用试验55号」加入手卡并公开，随后将此卡自身送回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送选择加入手卡卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组或墓地选择1张「GMX应用试验55号」（考虑王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家公开确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将此卡自身送回卡组并洗牌
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- 效果2的发动条件，检查导致此卡特殊召唤的效果是否为怪兽的效果
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 过滤条件，筛选墓地中属于「GMX」系列或恐龙族且可以返回卡组的卡片
function s.tdfilter(c,e)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR)) and c:IsAbleToDeck()
end
-- 效果2的Target，选择己方墓地合计2张「GMX」卡或恐龙族怪兽作为对象，并设置返回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查己方墓地是否存在合计至少2张可作为对象的「GMX」卡或恐龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家发送选择返回卡组卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择己方墓地合计2张符合条件的卡片作为效果的对象
	local tg=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息，即预计会将选为对象的卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
-- 效果2的Operation，将对象卡片以喜欢顺序送回卡组最上方，之后可选择破坏对方场上1只表侧攻击表示怪兽
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍然符合对象关系的卡片，并过滤受王家长眠之谷影响的卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()==0 then return end
	-- 将对象卡片送回卡组最上方，若实际返回卡组数量为0则结束效果处理
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 获取本次操作中实际送回主卡组的卡片数量
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	-- 若有卡片送回主卡组，则由玩家对卡组最上方的这些卡按喜欢的顺序进行重新排列
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 检查对方场上是否存在表侧攻击表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
		-- 询问玩家是否选择破坏对方场上的1只怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 给玩家发送选择破坏卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1只表侧攻击表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_ATTACK)
		if g:GetCount()>0 then
			-- 中断当前效果，使之后的破坏怪兽处理与返回卡组不视为同时处理
			Duel.BreakEffect()
			-- 手动为选定的破坏怪兽显示对象动画并进行对象记录
			Duel.HintSelection(g)
			-- 将选中的怪兽以效果原因破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
