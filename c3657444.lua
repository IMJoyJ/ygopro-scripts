--サイバー・ヴァリー
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●这张卡被选择作为攻击对象时，把这张卡除外才能发动。自己从卡组抽1张，那之后战斗阶段结束。
-- ●以自己场上1只表侧表示怪兽和这张卡为对象才能发动。那只自己的表侧表示怪兽和这张卡除外，那之后自己从卡组抽2张。
-- ●以自己墓地1张卡为对象才能发动。场上的这张卡和1张手卡除外，那之后作为对象的卡回到卡组最上面。
function c3657444.initial_effect(c)
	-- 这张卡被选择作为攻击对象时，把这张卡除外才能发动。自己从卡组抽1张，那之后战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3657444,0))  --"除外这张卡，抽卡并结束战斗阶段"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCost(c3657444.cost1)
	e1:SetTarget(c3657444.target1)
	e1:SetOperation(c3657444.operation1)
	c:RegisterEffect(e1)
	-- 以自己场上1只表侧表示怪兽和这张卡为对象才能发动。那只自己的表侧表示怪兽和这张卡除外，那之后自己从卡组抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3657444,1))  --"除外其他怪兽和这张卡，抽2张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c3657444.target2)
	e2:SetOperation(c3657444.operation2)
	c:RegisterEffect(e2)
	-- 以自己墓地1张卡为对象才能发动。场上的这张卡和1张手卡除外，那之后作为对象的卡回到卡组最上面。
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
-- 第一个效果的代价函数：检测这张卡能否作为代价除外；若可以，则将其表侧除外作为发动代价。
function c3657444.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将这张卡以表侧表示除外，作为效果发动的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 第一个效果的发动条件函数：检测玩家能否抽1张卡；若可以，则登记抽卡的操作信息。
function c3657444.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定：玩家是否可以进行1张卡的抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 登记连锁的操作信息：效果处理时让玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 第一个效果的解决函数：抽1张卡；若抽卡成功，则跳过战斗阶段。
function c3657444.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时让自己抽1张卡，并判断是否实际抽卡成功。
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 跳过对方玩家的战斗阶段，使其进入战斗阶段结束步骤。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end
-- 第二个效果选择对象用的过滤函数：选择自己场上表侧表示且可以被除外的怪兽。
function c3657444.filter2(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 第二个效果的取对象判定函数：校验对象选择条件，要求自身可除外、能抽2张卡且场上有1只除此卡外的表侧可除外怪兽。
function c3657444.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c3657444.filter2(chkc) end
	-- 发动时判定：这张卡自身能否被除外，且自己能否抽2张卡。
	if chk==0 then return c:IsAbleToRemove() and Duel.IsPlayerCanDraw(tp,2)
		-- 发动时判定：自己场上是否存在1只除此卡以外的表侧表示且可除外的怪兽，且这张卡本身能否成为效果对象。
		and Duel.IsExistingTarget(c3657444.filter2,tp,LOCATION_MZONE,0,1,c) and c:IsCanBeEffectTarget() end
	-- 向对方玩家提示我方发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 显示“请选择要除外的卡”的提示，用于选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足过滤条件且不是这张卡的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c3657444.filter2,tp,LOCATION_MZONE,0,1,1,c)
	g:AddCard(c)
	-- 登记连锁的操作信息：效果处理时将此对象怪兽和这张卡共2张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
	-- 登记连锁的操作信息：效果处理时让玩家抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 第二个效果的解决函数：确认对象怪兽和这张卡仍可除外后，将二者除外并抽2张卡。
function c3657444.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsFaceup() and c:IsRelateToEffect(e)
		and c:IsAbleToRemove() and tc:IsAbleToRemove() then
		local sg=Group.FromCards(c,tc)
		-- 将对象怪兽和这张卡以表侧表示一并除外；若没能除外2张，则终止后续处理。
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=2 then return end
		-- 中断当前效果处理，使抽卡视为单独处理，避免错过时点。
		Duel.BreakEffect()
		-- 效果处理时让自己抽2张卡。
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
-- 第三个效果的取对象判定函数：校验自身可除外、手牌有可除外的卡且墓地有可返回卡组的对象，并登记操作信息。
function c3657444.target3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return e:GetHandler():IsAbleToRemove()
		-- 判定自己手牌中是否存在至少1张可以除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil)
		-- 判定自己墓地中是否存在至少1张可以作为对象返回卡组的卡。
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示我方发动了该效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 显示“请选择要返回卡组的卡”的提示，用于选择墓地对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1张可以返回卡组的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记连锁的操作信息：效果处理时将场上的这张卡和1张手卡共2张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,0,0)
	-- 登记连锁的操作信息：效果处理时将对象墓地卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 第三个效果的解决函数：选择1张手牌与这张卡一同除外；成功后将对象墓地卡返回卡组最上面。
function c3657444.operation3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 显示“请选择要除外的卡”的提示，用于选择1张手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1张可以除外的卡（用于除外）。
	local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	if hg:GetCount()>0 then
		hg:AddCard(c)
		-- 将选择的手牌与这张卡一并除外；若没能除外2张，则终止后续处理。
		if Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)~=2 then return end
		-- 取得效果发动时选择的墓地对象卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使回卡组视为单独处理，避免错过时点。
			Duel.BreakEffect()
			-- 将对象墓地卡以效果送回持有者的卡组最上面。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	end
end
