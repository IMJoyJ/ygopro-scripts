--深海のセントリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡为让水属性怪兽的效果发动而被送去墓地的场合才能发动。对方选1张手卡直到结束阶段表侧表示除外。
-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把2张卡送去墓地，以「深海哨兵」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽加入手卡。
function c45483489.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡为让水属性怪兽的效果发动而被送去墓地的场合才能发动。对方选1张手卡直到结束阶段表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45483489,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,45483489)
	e1:SetCondition(c45483489.rmcon)
	e1:SetTarget(c45483489.rmtg)
	e1:SetOperation(c45483489.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把2张卡送去墓地，以「深海哨兵」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45483489,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,45483490)
	e2:SetCost(c45483489.thcost)
	e2:SetTarget(c45483489.thtg)
	e2:SetOperation(c45483489.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：本卡因水属性怪兽效果发动的代价被送去墓地时才可发动。具体判定本卡是否因COST送墓、该效果是否为发动的怪兽效果、该效果的处理者是否为水属性怪兽。
function c45483489.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 效果①的发动目标判定与操作登记：检查对方手牌是否存在能被除外的卡，存在则满足可发动条件，并登记‘除外对方手牌1张’的操作信息。
function c45483489.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅在检查发动合法性时（chk==0），检索对方手牌中是否存在至少1张能够被除外的卡，作为效果①能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,1-tp) end
	-- 登记本次效果处理时将从对方手牌除外1张卡（不取对象，由对方在效果处理时选择），用于后续连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果①实际处理：生成对方手牌可除外的卡集合；对方选择1张手牌；将其表侧除外；为该卡设置结束阶段返回手牌的标记与持续效果，实现‘直到结束阶段表侧表示除外’。
function c45483489.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方手牌中所有能够被除外的卡，组成候选集合供对方选择。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,1-tp)
	if g:GetCount()==0 then return end
	-- 向对方玩家发送‘请选择要除外的卡’的选择提示，引导其选出要除外的1张手牌。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	-- 把对方选中的手牌以表侧表示除外，完成‘表侧表示除外’的处理。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 对方选1张手卡直到结束阶段表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c45483489.retcon)
	e1:SetOperation(c45483489.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册一个在结束阶段触发的持续效果，用于把被暂时除外的卡送回手牌。
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(45483489,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
-- 返回效果的条件判断：检查被除外的卡是否仍保留本效果设置的标志且标志值一致，确认该卡确实是由本效果暂时除外的，才允许在结束阶段返回；若标志已丢失则清除该效果。
function c45483489.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(45483489)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行返回效果：将被暂时除外的卡送回持有者手牌。
function c45483489.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因把被暂时除外的卡送到其持有者的手卡，完成结束阶段的归还。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 效果②发动代价：从自己卡组上方将2张卡送去墓地。先检查能否支付，再实际执行送墓。
function c45483489.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在判定时（chk==0）检查自己能否将卡组上方2张卡作为代价送去墓地，若不能则效果②不能发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 实际将卡组上方2张卡送去墓地，作为效果②发动的COST。
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- 定义效果②的对象过滤条件：自己墓地中4星以下、水属性、卡名不是「深海哨兵」、且可以加入手卡的怪兽。
function c45483489.thfilter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(45483489) and c:IsAbleToHand()
end
-- 效果②的取对象处理：确认墓地存在符合条件的对象后，提示自己选择1张符合条件的墓地怪兽，并将其登记为效果对象，同时登记‘加入手卡’的操作信息。
function c45483489.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45483489.thfilter(chkc) end
	-- 在判定时（chk==0）检查自己墓地是否存在至少1张满足thfilter条件且能成为效果对象的卡，作为效果②能否发动的条件。
	if chk==0 then return Duel.IsExistingTarget(c45483489.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向自己玩家发送‘请选择要加入手牌的卡’的选择提示，引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己玩家从自己墓地选择1张满足条件的怪兽作为效果②的对象，同时将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c45483489.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本次效果将把对象卡加入手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理：取得对象卡，若仍与该效果关联，则将其加入手牌。
function c45483489.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因把对象卡送到其持有者的手卡，完成‘那只怪兽加入手卡’的处理。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
