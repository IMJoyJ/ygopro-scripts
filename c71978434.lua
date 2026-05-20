--深海のミンストレル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只水属性怪兽丢弃才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段表侧表示除外。
-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把3张卡送去墓地，以「深海吟游诗人」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽回到卡组最上面或者最下面。
function c71978434.initial_effect(c)
	-- ①：从手卡把这张卡和1只水属性怪兽丢弃才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71978434,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71978434)
	e1:SetCost(c71978434.rmcost)
	e1:SetTarget(c71978434.rmtg)
	e1:SetOperation(c71978434.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把3张卡送去墓地，以「深海吟游诗人」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽回到卡组最上面或者最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71978434,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,71978435)
	e2:SetCost(c71978434.tdcost)
	e2:SetTarget(c71978434.tdtg)
	e2:SetOperation(c71978434.tdop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可丢弃的水属性怪兽
function c71978434.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- 效果①的Cost（丢弃自身和1只水属性怪兽）判定与执行
function c71978434.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查手卡中是否存在除自身以外的水属性怪兽
		and Duel.IsExistingMatchingCard(c71978434.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择手卡中除自身以外的1只水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c71978434.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的怪兽作为Cost丢弃送去墓地
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动准备与效果分类注册（除外对方手卡）
function c71978434.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 设置效果处理信息为除外对方手卡的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果①的效果处理（确认对方手卡并除外1张，并在结束阶段归还）
function c71978434.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND,nil)
	if g:GetCount()==0 then return end
	-- 让己方玩家确认对方的所有手卡
	Duel.ConfirmCards(tp,g)
	local g1=g:Filter(Card.IsAbleToRemove,nil)
	-- 若对方手卡中没有可除外的卡，则将对方手卡洗切并结束效果处理
	if g1:GetCount()==0 then Duel.ShuffleHand(1-tp) return end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g1:Select(tp,1,1,nil):GetFirst()
	-- 将选中的对方手卡表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	-- 洗切对方的手卡
	Duel.ShuffleHand(1-tp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 直到结束阶段表侧表示除外。②：这张卡特殊召唤成功的场合，从自己卡组上面把3张卡送去墓地，以「深海吟游诗人」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽回到卡组最上面或者最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c71978434.retcon)
	e1:SetOperation(c71978434.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段将除外卡片加回手卡的时点效果
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(71978434,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
-- 检查被除外的卡片是否仍带有对应的标记，以决定是否在结束阶段归还
function c71978434.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(71978434)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 执行在结束阶段将除外的卡片送回手卡的操作
function c71978434.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将被除外的卡片送回持有者的手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- 效果②的Cost（从卡组上面把3张卡送去墓地）判定与执行
function c71978434.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方玩家是否能将卡组最上方的3张卡送去墓地作为Cost
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	-- 将己方卡组最上方的3张卡送去墓地
	Duel.DiscardDeck(tp,3,REASON_COST)
end
-- 过滤墓地中「深海吟游诗人」以外的4星以下的水属性怪兽
function c71978434.tdfilter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(71978434) and c:IsAbleToDeck()
end
-- 效果②的发动准备与目标选择（选择墓地中符合条件的怪兽）
function c71978434.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c71978434.tdfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c71978434.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c71978434.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息为将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的效果处理（将目标怪兽放回卡组最上面或最下面）
function c71978434.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsExtraDeckMonster()
			-- 提示玩家选择将卡片放回卡组最上面还是最下面
			or Duel.SelectOption(tp,aux.Stringid(71978434,2),aux.Stringid(71978434,3))==0 then  --"回到卡组最上面/回到卡组最下面"
			-- 将目标怪兽放回卡组最上面
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将目标怪兽放回卡组最下面
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
