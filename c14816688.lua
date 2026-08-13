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
	-- 这个卡名的②的效果1回合只能使用1次。②：把墓地的这张卡除外，以自己场上1张卡为对象才能发动。那张卡回到持有者卡组洗切，那之后自己从卡组抽1张。这个回合的结束阶段，自己1张手卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14816688,1))  --"回到卡组"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,14816688)
	-- 设置②效果的发动代价：从墓地除外这张卡自身。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c14816688.tdtg)
	e2:SetOperation(c14816688.tdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判断：自己场上没有怪兽存在的场合才可发动。
function c14816688.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上怪兽区域数量是否为0，即满足'自己场上没有怪兽存在'的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 对象的过滤条件：该墓地怪兽能够被当前效果特殊召唤（满足召唤条件且不违反苏生限制）。
function c14816688.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动时点：确认场上存在可用怪兽区域，并从自己墓地选择1只可特殊召唤的怪兽作为对象（取对象）。
function c14816688.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14816688.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域，以确保特殊召唤能进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只以上满足特殊召唤条件的怪兽可以作为对象。
		and Duel.IsExistingTarget(c14816688.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家从墓地选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的怪兽，并将其登记为这张效果的发动对象。
	local g=Duel.SelectTarget(tp,c14816688.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次连锁的处理信息：将对所选择的怪兽进行特殊召唤，供相关效果进行判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若场上仍有可用怪兽区域，则将对象怪兽以表侧表示特殊召唤，并对其附加效果无效化和结束阶段除外的处理。
function c14816688.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认有可用怪兽区域，否则直接结束不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取出发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与该效果关联，并尝试以表侧表示进行特殊召唤（作为特殊召唤流程的一步）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(14816688,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- ①：这个效果特殊召唤的怪兽的效果无效化，结束阶段除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(c14816688.rmcon1)
		e3:SetOperation(c14816688.rmop1)
		-- 将用于结束阶段除外对象怪兽的持续效果注册到当前玩家场上。
		Duel.RegisterEffect(e3,tp)
	end
	-- 完成特殊召唤流程，统一结算本次特殊召唤。
	Duel.SpecialSummonComplete()
end
-- 结束阶段除外效果的发动条件：确认对象怪兽仍保有本次特殊召唤时登记的标记，防止误除其他卡；若标记不符则重置该效果。
function c14816688.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(14816688)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的处理：将对象怪兽除外。
function c14816688.rmop1(e,tp,eg,ep,ev,re,r,rp)
	-- 将以表侧表示将对象怪兽除外，对应'结束阶段除外'。
	Duel.Remove(e:GetLabelObject(),POS_FACEUP,REASON_EFFECT)
end
-- ②效果的发动时点：确认自己可以抽1张卡，并选择自己场上1张可以返回手卡的卡作为对象（取对象）。
function c14816688.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查发动者是否可以抽1张卡（满足抽卡前提）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己场上是否存在1张以上可作为对象的卡（代码用能否返回手卡作为对象合法性判定）。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回卡组的自己场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家从自己场上选择1张可返回卡组的卡，并登记为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 登记操作信息：将所选择的1张卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记操作信息：之后从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：若对象卡仍关联且成功返回持有者卡组，则洗切卡组并抽1张；随后注册本回合结束阶段从手卡除外1张的效果。
function c14816688.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联，并将其返回持有者卡组；若返回成功且对象位于卡组/额外卡组则继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 若对象回到主卡组，则洗切对应玩家的卡组。
		if tc:IsLocation(LOCATION_DECK) then Duel.ShuffleDeck(tc:GetControler()) end
		-- 中断当前效果处理，使后面的抽卡成为独立处理，避免时点被吞。
		Duel.BreakEffect()
		-- 抽1张卡，对应'那之后自己从卡组抽1张'。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	-- 这个回合的结束阶段，自己1张手卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c14816688.rmop2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段从手卡除外1张的持续效果注册到当前玩家，限定本回合结束阶段适用。
	Duel.RegisterEffect(e1,tp)
end
-- rmop2：本回合结束阶段的处理，选择并除外自己1张手卡。
function c14816688.rmop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己手卡选择1张可以除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的手卡以表侧表示除外，对应'自己1张手卡除外'。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
