--深海の都 マガラニカ
-- 效果：
-- 这个卡名在规则上当作「海」使用。
-- ①：作为这张卡的发动时的效果处理，可以从卡组选1只水属性怪兽在卡组最上面放置。
-- ②：1回合1次，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升1星或者2星。
-- ③：1回合1次，自己主要阶段，自己对水属性同调怪兽的特殊召唤成功的场合才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段表侧表示除外。
function c26534688.initial_effect(c)
	-- 效果原文：①：作为这张卡的发动时的效果处理，可以从卡组选1只水属性怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c26534688.activate)
	c:RegisterEffect(e1)
	-- 效果原文：②：1回合1次，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升1星或者2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26534688,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c26534688.lvtg)
	e2:SetOperation(c26534688.lvop)
	c:RegisterEffect(e2)
	-- 效果原文：③：1回合1次，自己主要阶段，自己对水属性同调怪兽的特殊召唤成功的场合才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段表侧表示除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26534688,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c26534688.rmcon)
	e3:SetTarget(c26534688.rmtg)
	e3:SetOperation(c26534688.rmop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的水属性怪兽组并判断是否选择发动效果
function c26534688.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组中所有水属性怪兽
	local g=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_DECK,0,nil,ATTRIBUTE_WATER)
	-- 判断卡组中存在水属性怪兽且玩家选择发动效果
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(26534688,2)) then  --"是否从卡组选1只水属性怪兽在卡组最上面放置？"
		-- 提示玩家选择要放置到卡组最上方的水属性怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26534688,3))  --"请选择要在卡组最上面放置的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将玩家卡组洗切
		Duel.ShuffleDeck(tp)
		-- 将选择的水属性怪兽移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认玩家卡组最上方的卡
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 判断目标怪兽是否为表侧表示的水属性怪兽且等级大于等于1
function c26534688.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(1)
end
-- 设置效果目标，选择满足条件的水属性怪兽
function c26534688.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26534688.lvfilter(chkc) end
	-- 判断是否存在满足条件的水属性怪兽作为效果目标
	if chk==0 then return Duel.IsExistingTarget(c26534688.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的水属性怪兽作为效果对象
	Duel.SelectTarget(tp,c26534688.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果，使目标怪兽等级上升
function c26534688.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要上升等级的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26534688,4))  --"请选择要上升等级的怪兽"
		-- 让玩家宣言要上升的等级（1或2）
		local lv=Duel.AnnounceNumber(tp,1,2)
		-- 创建等级变更效果并注册给目标怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断目标怪兽是否为表侧表示的水属性同调怪兽且为玩家召唤
function c26534688.rmfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_SYNCHRO) and c:IsSummonPlayer(tp)
end
-- 设置效果发动条件，判断是否为玩家主要阶段且有水属性同调怪兽特殊召唤成功
function c26534688.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为玩家回合且处于主要阶段且有水属性同调怪兽特殊召唤成功
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and eg:IsExists(c26534688.rmfilter,1,nil,tp)
end
-- 设置效果处理时的确认手卡并选择除外的卡
function c26534688.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手卡是否存在可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 设置操作信息，确定要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 处理效果，确认对方手卡并选择除外的卡
function c26534688.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中所有可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()==0 then return end
	-- 确认玩家对方手卡
	Duel.ConfirmCards(tp,g)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选择的卡除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	-- 将对方手卡洗切
	Duel.ShuffleHand(1-tp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 注册结束阶段的返回手卡效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c26534688.retcon)
	e1:SetOperation(c26534688.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(26534688,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
-- 判断是否为需要返回手卡的卡
function c26534688.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(26534688)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将卡返回手卡
function c26534688.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将卡送回手卡
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
