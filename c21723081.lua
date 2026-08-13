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
	-- 这个卡名的①的效果1回合只能使用1次。①：「XYZ-神龙炮」或者有那个卡名作为融合素材记述的融合怪兽在自己场上存在的场合，可以把这个效果的发动回合的以下效果发动。●自己回合：以除外的1只自己的同盟怪兽为对象才能发动。那只怪兽回到卡组最下面，自己从卡组抽1张。●对方回合：把手卡任意数量丢弃，以那个数量的对方场上的卡为对象才能发动。那些卡破坏。
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
-- 检测场上是否存在满足发动条件的怪兽：表侧表示的「XYZ-神龙炮」，或融合素材中记述了「XYZ-神龙炮」的表侧表示融合怪兽。
function c21723081.cfilter(c)
	-- 判断当前怪兽是否为表侧表示，并且卡名为「XYZ-神龙炮」，或者是融合素材中记述了「XYZ-神龙炮」的表侧表示融合怪兽。
	return c:IsFaceup() and (c:IsCode(91998119) or c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,91998119))
end
-- 效果发动条件：检查己方主要怪兽区是否存在至少1只满足cfilter条件的怪兽。
function c21723081.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上（LOCATION_MZONE）是否存在至少1张符合cfilter条件的卡。
	return Duel.IsExistingMatchingCard(c21723081.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义可返回卡组底的对象筛选：表侧表示的同盟怪兽且能被返回卡组。
function c21723081.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_UNION) and c:IsAbleToDeck()
end
-- 发动时的目标选择与合法性判定：根据当前回合是否为发动者，分别处理自己回合（除外区选同盟怪兽回卡组并抽卡）和对方回合（丢弃手卡并选破坏对象）的发动选择。
function c21723081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断当前回合是否为这张卡的控制者的回合，以选择对应的分支效果。
	if Duel.GetTurnPlayer()==tp then
		if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c21723081.tdfilter(chkc) end
		-- 自己回合分支的发动合法性检查：除外区是否存在1只己方表侧同盟怪兽可作为对象，且己方可以抽1张卡。
		if chk==0 then return Duel.IsExistingTarget(c21723081.tdfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
			-- 继续检查己方是否能够抽1张卡（作为抽卡效果的前提）。
			and Duel.IsPlayerCanDraw(tp,1) end
		e:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
		-- 向发动者显示“请选择要返回卡组的卡”的提示信息，用于后续选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从己方除外区选择1张满足tdfilter的同盟怪兽作为效果对象。
		local g=Duel.SelectTarget(tp,c21723081.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		-- 将“返回卡组”作为本次效果的处理信息，指定对象g和数量1。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		-- 将“抽卡”作为本次效果的处理信息，抽卡玩家为tp，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	else
		if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
		-- 对方回合分支的发动合法性检查：对方场上有可以被破坏的卡，且己方手牌中有可以丢弃的卡。
		if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
			-- 继续检查己方手牌中是否存在至少1张可以丢弃的卡。
			and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
		e:SetCategory(CATEGORY_DESTROY)
		-- 统计对方场上当前的卡的数量，作为最多可丢弃手牌的数量。
		local rt=Duel.GetTargetCount(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 作为发动代价，让对方从手卡丢弃1到rt张卡（rt为对方场上卡数），实际丢弃数ct用于后续选择破坏对象。
		local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,rt,REASON_COST+REASON_DISCARD,nil)
		-- 向发动者显示“请选择要破坏的卡”的提示信息，用于后续选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上ct张卡作为破坏对象（ct为丢弃的手卡数量）。
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		-- 将“破坏”作为本次效果的处理信息，指定对象g和数量ct。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
	end
end
-- 效果处理：根据当前回合分别执行——自己回合将对象怪兽返回卡组底并抽1张；对方回合将对象卡片破坏。
function c21723081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时判断当前回合玩家，以执行对应的分支。
	if Duel.GetTurnPlayer()==tp then
		-- 取回自己回合发动时选择的对象卡（除外区的同盟怪兽）。
		local tc=Duel.GetFirstTarget()
		-- 若对象仍与效果关联，将其返回卡组最下面；返回成功且该卡在卡组中时，继续执行抽卡。
		if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK) then
			-- 己方抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	else
		-- 取回对方回合发动时选择的所有对象卡（破坏对象）。
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local rg=tg:Filter(Card.IsRelateToEffect,nil,e)
		if rg:GetCount()>0 then
			-- 将仍与效果关联的对象卡全部破坏。
			Duel.Destroy(rg,REASON_EFFECT)
		end
	end
end
