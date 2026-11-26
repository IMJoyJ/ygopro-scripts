--魔救の奇跡－ラプタイト
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只岩石族怪兽守备表示特殊召唤。剩下的卡用喜欢的顺序回到卡组最下面。
-- ②：对方回合，自己墓地有风属性怪兽存在的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
function c73079836.initial_effect(c)
	-- 注册同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只岩石族怪兽守备表示特殊召唤。剩余用喜欢的顺序回到卡组下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73079836,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,73079836)
	e1:SetTarget(c73079836.sptg)
	e1:SetOperation(c73079836.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，自己墓地有风属性怪兽存在的场合，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73079836,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,73079837)
	e2:SetCondition(c73079836.rmcon)
	e2:SetTarget(c73079836.rmtg)
	e2:SetOperation(c73079836.rmop)
	c:RegisterEffect(e2)
end
-- ①效果的目标处理函数：检查自己卡组是否至少有5张卡可供翻开。
function c73079836.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组至少剩余5张卡。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤条件：检查卡片是否为可以表侧守备表示特殊召唤的岩石族怪兽。
function c73079836.spfilter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的处理函数：翻开自己卡组最上方5张卡，若有空位且有岩石族怪兽可选择1只守备表示特招，其余以喜欢顺序放回卡组最下面。
function c73079836.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时检查自己卡组是否仍有至少5张卡，不足则结束处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=4 then return end
	-- 向双方翻开确认自己卡组最上方5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 获取自己卡组最上方5张卡组成的卡片组。
	local g=Duel.GetDecktopGroup(tp,5)
	local ct=g:GetCount()
	-- 检查翻开的卡数量大于0、自己怪兽区有空位且翻开的卡中存在可特殊召唤的岩石族怪兽。
	if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:FilterCount(c73079836.spfilter,nil,e,tp)>0
		-- 询问玩家是否从翻开的卡中特殊召唤1只岩石族怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(73079836,2)) then  --"是否特殊召唤怪兽？"
		-- 禁用洗卡检测，以便后续将剩余卡片按顺序放回卡组最下面。
		Duel.DisableShuffleCheck()
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:FilterSelect(tp,c73079836.spfilter,1,1,nil,e,tp)
		-- 将所选岩石族怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		ct=g:GetCount()-sg:GetCount()
	end
	if ct>0 then
		-- 让己方对剩余的卡组顶卡片进行排序。
		Duel.SortDecktop(tp,tp,ct)
		for i=1,ct do
			-- 获取当前位于卡组最上方的1张卡。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将该卡移动到自己卡组的最下面。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- ②效果的发动条件：检查当前是否为对方回合，且自己墓地存在风属性怪兽。
function c73079836.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方，以及自己墓地是否存在至少1只风属性怪兽。
	return Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_WIND)
end
-- ②效果的目标处理函数：检查并选取对方墓地1张可除外的卡作为对象，并设置除外操作信息。
function c73079836.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 发动条件检查：确认对方墓地存在至少1张可以作为对象并除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 发送提示信息，引导玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让己方从对方墓地选择1张可除外的卡作为对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：预计将所选定的对方墓地卡片除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理函数：校验对象卡仍与效果保持联系后将其表侧表示除外。
function c73079836.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁指定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以效果表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
