--X・Y・Zハイパーキャノン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：「XYZ-神龙炮」或者有那个卡名作为融合素材记述的融合怪兽在自己场上存在的场合，可以把这个效果的发动回合的以下效果发动。
-- ●自己回合：以除外的1只自己的同盟怪兽为对象才能发动。那只怪兽回到卡组最下面，自己从卡组抽1张。
-- ●对方回合：把手卡任意数量丢弃，以那个数量的对方场上的卡为对象才能发动。那些卡破坏。
function c21723081.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：这个卡名的①的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21723081,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,21723081)
	e2:SetCondition(c21723081.condition)
	e2:SetTarget(c21723081.target)
	e2:SetOperation(c21723081.operation)
	c:RegisterEffect(e2)
end
c21723081.has_text_type=TYPE_UNION
-- 效果作用：检测场上是否存在「XYZ-神龙炮」或以它为融合素材的融合怪兽
function c21723081.cfilter(c)
	-- 效果作用：判断怪兽是否为「XYZ-神龙炮」或以它为融合素材的融合怪兽
	return c:IsFaceup() and (c:IsCode(91998119) or c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,91998119))
end
-- 效果原文内容：①：「XYZ-神龙炮」或者有那个卡名作为融合素材记述的融合怪兽在自己场上存在的场合，可以把这个效果的发动回合的以下效果发动。
function c21723081.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否存在符合条件的怪兽
	return Duel.IsExistingMatchingCard(c21723081.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：过滤满足条件的同盟怪兽
function c21723081.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_UNION) and c:IsAbleToDeck()
end
-- 效果原文内容：●自己回合：以除外的1只自己的同盟怪兽为对象才能发动。那只怪兽回到卡组最下面，自己从卡组抽1张。●对方回合：把手卡任意数量丢弃，以那个数量的对方场上的卡为对象才能发动。那些卡破坏。
function c21723081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 效果作用：判断是否为己方回合
	if Duel.GetTurnPlayer()==tp then
		if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c21723081.tdfilter(chkc) end
		-- 效果作用：检查己方除外区是否存在满足条件的同盟怪兽
		if chk==0 then return Duel.IsExistingTarget(c21723081.tdfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
			-- 效果作用：检查己方是否可以抽1张卡
			and Duel.IsPlayerCanDraw(tp,1) end
		e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
		-- 效果作用：提示选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 效果作用：选择满足条件的除外区同盟怪兽
		local g=Duel.SelectTarget(tp,c21723081.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 效果作用：设置操作信息为将卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 效果作用：设置操作信息为抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
		-- 效果作用：检查对方场上是否存在满足条件的卡
		if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
			-- 效果作用：检查己方手牌中是否存在可丢弃的卡
			and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
		e:SetCategory(CATEGORY_DESTROY)
		-- 效果作用：获取对方场上的卡的数量
		local rt=Duel.GetTargetCount(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 效果作用：丢弃手牌中满足条件的卡
		local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,rt,REASON_COST+REASON_DISCARD,nil)
		-- 效果作用：提示选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 效果作用：选择满足条件的对方场上的卡
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		-- 效果作用：设置操作信息为破坏卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
	end
end
-- 效果作用：处理效果的发动
function c21723081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否为己方回合
	if Duel.GetTurnPlayer()==tp then
		-- 效果作用：获取连锁对象卡
		local tc=Duel.GetFirstTarget()
		-- 效果作用：将对象卡送回卡组最底端并确认是否成功
		if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
			-- 效果作用：从卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		-- 效果作用：获取连锁对象卡组
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
		if rg:GetCount()>0 then
			-- 效果作用：破坏对象卡
			Duel.Destroy(rg,REASON_EFFECT)
		end
	end
end
