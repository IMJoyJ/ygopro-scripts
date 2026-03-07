--サイバー・ヴァリー
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●这张卡被选择作为攻击对象时，把这张卡除外才能发动。自己从卡组抽1张，那之后战斗阶段结束。
-- ●以自己场上1只表侧表示怪兽和这张卡为对象才能发动。那只自己的表侧表示怪兽和这张卡除外，那之后自己从卡组抽2张。
-- ●以自己墓地1张卡为对象才能发动。场上的这张卡和1张手卡除外，那之后作为对象的卡回到卡组最上面。
function c3657444.initial_effect(c)
	-- 效果原文：这张卡被选择作为攻击对象时，把这张卡除外才能发动。自己从卡组抽1张，那之后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3657444,0))  --"除外这张卡，抽卡并结束战斗阶段"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCost(c3657444.cost1)
	e1:SetTarget(c3657444.target1)
	e1:SetOperation(c3657444.operation1)
	c:RegisterEffect(e1)
	-- 效果原文：以自己场上1只表侧表示怪兽和这张卡为对象才能发动。那只自己的表侧表示怪兽和这张卡除外，那之后自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3657444,1))  --"除外其他怪兽和这张卡，抽2张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c3657444.target2)
	e2:SetOperation(c3657444.operation2)
	c:RegisterEffect(e2)
	-- 效果原文：以自己墓地1张卡为对象才能发动。场上的这张卡和1张手卡除外，那之后作为对象的卡回到卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3657444,2))  --"除外手卡和这张卡，回收墓地"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c3657444.target3)
	e3:SetOperation(c3657444.operation3)
	c:RegisterEffect(e3)
end
-- 规则层面：检查是否满足除外自身作为cost的条件，并执行除外操作
function c3657444.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 规则层面：将自身从游戏中除外作为发动cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 规则层面：检查玩家是否可以抽1张卡，并设置操作信息
function c3657444.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面：设置操作信息，表示将要进行抽卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面：执行抽卡并跳过战斗阶段
function c3657444.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断是否成功抽卡
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		-- 规则层面：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面：跳过对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 规则层面：定义过滤函数，用于筛选场上正面表示且可除外的怪兽
function c3657444.filter2(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 规则层面：设置效果目标选择函数，用于选择场上正面表示的怪兽
function c3657444.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c3657444.filter2(chkc) end
	-- 规则层面：检查是否可以除外自身并抽2张卡
	if chk==0 then return c:IsAbleToRemove() and Duel.IsPlayerCanDraw(tp,2)
		-- 规则层面：检查场上是否存在正面表示且可除外的怪兽
		and Duel.IsExistingTarget(c3657444.filter2,tp,LOCATION_MZONE,0,1,c) and c:IsCanBeEffectTarget() end
	-- 规则层面：向对方提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面：提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面：选择场上正面表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c3657444.filter2,tp,LOCATION_MZONE,0,1,1,c)
	g:AddCard(c)
	-- 规则层面：设置操作信息，表示将要除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
	-- 规则层面：设置操作信息，表示将要进行抽2张卡操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 规则层面：执行效果操作，将目标怪兽和自身除外并抽2张卡
function c3657444.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsFaceup() and c:IsRelateToEffect(e)
		and c:IsAbleToRemove() and tc:IsAbleToRemove() then
		local sg=Group.FromCards(c,tc)
		-- 规则层面：判断是否成功除外2张卡
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=2 then return end
		-- 规则层面：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面：执行抽2张卡操作
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- 规则层面：设置效果目标选择函数，用于选择墓地中的卡
function c3657444.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 规则层面：检查手牌中是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil)
		-- 规则层面：检查墓地中是否存在可送回卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：向对方提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 规则层面：提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面：选择墓地中的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面：设置操作信息，表示将要除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,0,0)
	-- 规则层面：设置操作信息，表示将要送回卡组1张卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 规则层面：执行效果操作，将手牌和自身除外并送回墓地卡
function c3657444.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面：选择手牌中1张卡作为除外对象
	local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	if hg:GetCount()>0 then
		hg:AddCard(c)
		-- 规则层面：判断是否成功除外2张卡
		if Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)~=2 then return end
		-- 规则层面：获取当前效果的目标卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 规则层面：中断当前效果处理
			Duel.BreakEffect()
			-- 规则层面：将目标卡送回卡组顶部
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
