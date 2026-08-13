--GMX主任教授キンリッジ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的卡组·墓地把1张「第55次基因组混合应用试验」加入手卡，这张卡回到卡组。
-- ②：这张卡用怪兽的效果特殊召唤的场合，以自己墓地的「基因组混合」卡或恐龙族怪兽合计2张为对象才能发动。那些卡用喜欢的顺序回到卡组上面。那之后，可以把对方场上1只攻击表示怪兽破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册记载卡名，创建①效果（手卡起动检索）和②效果（特殊召唤诱发回卡组·破坏）
function s.initial_effect(c)
	-- 在这张卡上登记记载有「第55次基因组混合应用试验」的卡名（供记述检测使用）
	aux.AddCodeList(c,18795635)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的卡组·墓地把1张「第55次基因组混合应用试验」加入手卡，这张卡回到卡组。
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
	-- ②：这张卡用怪兽的效果特殊召唤的场合，以自己墓地的「基因组混合」卡或恐龙族怪兽合计2张为对象才能发动。那些卡用喜欢的顺序回到卡组上面。那之后，可以把对方场上1只攻击表示怪兽破坏。
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
-- ①效果的发动代价检测：要求手卡的这张卡处于未公开状态（发动时将其给对方观看）
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 检索过滤条件：是「第55次基因组混合应用试验」且可以加入手卡
function s.thfilter(c)
	return c:IsCode(18795635) and c:IsAbleToHand()
end
-- ①效果的目标处理：检查卡组·墓地是否存在可检索的卡且这张卡能回卡组，并设置加入手卡和回卡组的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动可行性检测：自己的卡组·墓地存在满足条件的卡，且这张卡可以回到卡组
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and c:IsAbleToDeck() end
	-- 设置操作信息：预计从卡组·墓地把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 设置操作信息：预计把这张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- ①效果的处理：从自己的卡组·墓地选1张「第55次基因组混合应用试验」加入手卡，然后这张卡回到卡组并洗切
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家提示请选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从卡组·墓地选择1张满足条件且不受王家长眠之谷影响的「第55次基因组混合应用试验」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 把这张卡返回卡组并洗切卡组
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡是用怪兽的效果特殊召唤的
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 对象过滤条件：是自己墓地的「基因组混合」卡或恐龙族怪兽，且可以回到卡组
function s.tdfilter(c,e)
	return (c:IsSetCard(0x1dd) or c:IsRace(RACE_DINOSAUR)) and c:IsAbleToDeck()
end
-- ②效果的目标处理：检查并选择自己墓地的「基因组混合」卡或恐龙族怪兽合计2张为对象，设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动可行性检测：自己墓地存在合计2张可以作为对象的满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家提示请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让自己玩家选择自己墓地合计2张「基因组混合」卡或恐龙族怪兽作为效果对象
	local tg=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置操作信息：预计把作为对象的2张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,tg:GetCount(),0,0)
end
-- ②效果的处理：把对象的卡用喜欢的顺序回到卡组上面，那之后可以把对方场上1只攻击表示怪兽破坏
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回与本次连锁相关的对象卡，并过滤掉受王家长眠之谷影响的卡
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()==0 then return end
	-- 把对象的卡返回卡组最上面，若没有卡成功返回则中断处理
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
	-- 统计实际被回到卡组（而非额外卡组）的卡的数量
	local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	-- 让自己玩家对卡组最上方的这些卡按喜欢的顺序排列
	if ct>0 then Duel.SortDecktop(tp,tp,ct) end
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 检测对方场上是否存在攻击表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_ATTACK)
		-- 询问玩家是否要把对方场上的怪兽破坏
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
		-- 向玩家提示请选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让自己玩家选择对方场上1只攻击表示怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_ATTACK)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使之后的破坏处理与前面的回卡组视为不同时处理
			Duel.BreakEffect()
			-- 为选中的怪兽显示被选为对象的动画提示
			Duel.HintSelection(g)
			-- 把选中的对方怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
