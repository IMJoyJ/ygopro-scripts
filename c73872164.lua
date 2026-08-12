--お家おとりつぶし
-- 效果：
-- ①：从手卡丢弃1张魔法卡，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。那之后，有对方手卡的场合，把对方手卡确认，破坏的卡的同名卡全部送去墓地。
function c73872164.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽破坏。那之后，有对方手卡的场合，把对方手卡确认，破坏的卡的同名卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c73872164.cost)
	e1:SetTarget(c73872164.target)
	e1:SetOperation(c73872164.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中的魔法卡且可以丢弃
function c73872164.cfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 发动代价（Cost）处理：检查并从手牌丢弃1张魔法卡
function c73872164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌是否存在除这张卡以外的、可丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73872164.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌丢弃1张满足条件的魔法卡作为发动代价
	Duel.DiscardHand(tp,c73872164.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：表侧表示的怪兽
function c73872164.filter(c)
	return c:IsFaceup()
end
-- 效果的目标选择（Target）处理：选择对方场上1只表侧表示怪兽为对象
function c73872164.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c73872164.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c73872164.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c73872164.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果运行（Operation）处理：破坏对象怪兽，确认对方手牌并送去同名卡
function c73872164.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果且呈表侧表示，并将其破坏
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断效果连接，使后续的确认手牌和送去墓地处理视为不同时处理（那之后）
		Duel.BreakEffect()
		local code=tc:GetCode()
		-- 获取对方手牌中与被破坏怪兽同名的卡片组
		local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,code)
		-- 获取对方的全部手牌
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		-- 让己方玩家确认对方的全部手牌
		Duel.ConfirmCards(tp,hg)
		if g:GetCount()>0 then
			-- 将对方手牌中与被破坏怪兽同名的卡全部送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
		-- 重新洗切对方的手牌
		Duel.ShuffleHand(1-tp)
	end
end
