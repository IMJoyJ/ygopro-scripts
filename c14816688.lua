--シャッフル・リボーン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
-- ②：把墓地的这张卡除外，以自己场上1张卡为对象才能发动。那张卡回到持有者卡组洗切，那之后自己从卡组抽1张。这个回合的结束阶段，自己1张手卡除外。
function c14816688.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14816688,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c14816688.condition)
	e1:SetTarget(c14816688.target)
	e1:SetOperation(c14816688.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1张卡为对象才能发动。那张卡回到持有者卡组洗切，那之后自己从卡组抽1张。这个回合的结束阶段，自己1张手卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14816688,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,14816688)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c14816688.tdtg)
	e2:SetOperation(c14816688.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己场上没有怪兽存在
function c14816688.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp的场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 用于筛选可以特殊召唤的墓地怪兽
function c14816688.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动时选择对象
function c14816688.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14816688.filter(chkc,e,tp) end
	-- 检查是否满足特殊召唤的条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足特殊召唤的条件：墓地存在可特殊召唤的怪兽
		and Duel.IsExistingTarget(c14816688.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择要特殊召唤的墓地怪兽
	local g=Duel.SelectTarget(tp,c14816688.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果①的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理流程
function c14816688.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果①选择的对象
	local tc=Duel.GetFirstTarget()
	-- 执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(14816688,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 设置特殊召唤怪兽在结束阶段除外的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c14816688.rmcon1)
		e3:SetOperation(c14816688.rmop1)
		-- 注册结束阶段除外的效果
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 判断特殊召唤怪兽是否仍存在
function c14816688.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(14816688)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行特殊召唤怪兽的除外效果
function c14816688.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽除外
	Duel.Remove(e:GetLabelObject(),POS_FACEUP,REASON_EFFECT)
end
-- 效果②的发动时选择对象
function c14816688.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查是否满足效果②的条件：可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查是否满足效果②的条件：场上存在可送回卡组的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择要送回卡组的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果②的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置效果②的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的处理流程
function c14816688.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象
	local tc=Duel.GetFirstTarget()
	-- 将对象卡送回卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 如果送回卡组的卡在卡组中，则洗切卡组
		if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 从卡组抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	-- 设置效果②在结束阶段除外手卡的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c14816688.rmop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册结束阶段除外手卡的效果
	Duel.RegisterEffect(e1,tp)
end
-- 执行结束阶段除外手卡的效果
function c14816688.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择要除外的手卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
