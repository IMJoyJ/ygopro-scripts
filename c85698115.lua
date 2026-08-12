--幽世離レ
-- 效果：
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。那之后，可以把对方场上1只怪兽除外。那个场合，再让对方的除外状态的1只怪兽回到墓地。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只1星怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把「常世离」「现世离」「幽世离」的其中1张在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果：①卡片发动时的特殊召唤·除外·回墓效果，②墓地发动时的回卡组·卡组盖放效果。
function c85698115.initial_effect(c)
	-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。那之后，可以把对方场上1只怪兽除外。那个场合，再让对方的除外状态的1只怪兽回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以自己墓地1只1星怪兽为对象才能发动。那只怪兽回到卡组。那之后，可以从卡组把「常世离」「现世离」「幽世离」的其中1张在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置效果②的发动条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：能在对方场上正面表示特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果①的发动准备与合法性检测（包含怪兽区域空格检查和墓地目标存在检查）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 检查对方场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在可以特殊召唤的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送提示信息：选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤分类，操作对象为选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：对方除外状态的正面表示怪兽。
function s.rtfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 效果①的效果处理：特殊召唤目标怪兽，之后可选择除外对方场上1只怪兽，若除外成功则再让对方除外状态的1只怪兽回到墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的特殊召唤目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍存在，则将其在对方场上正面表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)~=0 then
		-- 获取对方场上可以被除外的怪兽组。
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
		-- 若对方场上有可除外的怪兽，询问玩家是否进行除外操作。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选怪兽除外？"
			-- 向玩家发送提示信息：选择要除外的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 选中要除外的怪兽并显示选择框。
			Duel.HintSelection(sg)
			-- 将选中的怪兽除外，若除外成功则继续处理后续效果。
			if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 then
			-- 获取对方除外状态的正面表示怪兽组。
			local rg=Duel.GetMatchingGroup(s.rtfilter,tp,0,LOCATION_REMOVED,nil)
				if rg:GetCount()>0 then
					-- 向玩家发送提示信息：选择要送去墓地的卡。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
					local fg=rg:Select(tp,1,1,nil)
					-- 选中要回到墓地的怪兽并显示选择框。
					Duel.HintSelection(fg)
					-- 将选中的除外状态怪兽送回墓地。
					Duel.SendtoGrave(fg,REASON_EFFECT+REASON_RETURN)
				end
			end
		end
	end
end
-- 过滤条件：自己墓地中可以回到卡组的1星怪兽。
function s.rfilter(c)
	return c:IsLevel(1) and c:IsAbleToDeck()
end
-- 过滤条件：卡组中非禁止且可以盖放的「常世离」、「现世离」或「幽世离」。
function s.stfilter(c)
	return c:IsCode(63086455,11110218,id) and not c:IsForbidden() and c:IsSSetable()
end
-- 效果②的发动准备与合法性检测（选择自己墓地1只1星怪兽作为对象，并设置回卡组的连锁信息）。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.rfilter(chkc) end
	-- 检查自己墓地是否存在可以回到卡组的1星怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息：选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只1星怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息：包含回到卡组分类，操作对象为选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的效果处理：使目标怪兽回到卡组，之后可以从卡组将1张「常世离」、「现世离」或「幽世离」在自己场上盖放。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的回到卡组的目标怪兽。
	local rc=Duel.GetFirstTarget()
	-- 若目标怪兽仍存在，则将其送回卡组并洗牌，确认其已成功回到卡组或额外卡组。
	if rc:IsRelateToEffect(e) and Duel.SendtoDeck(rc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and rc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果，使后续的盖放处理与回卡组处理不视为同时进行。
		Duel.BreakEffect()
		-- 获取自己卡组中满足条件的「常世离」、「现世离」或「幽世离」卡片组。
		local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_DECK,0,nil)
		-- 若卡组中存在可盖放的卡，询问玩家是否进行盖放。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1))then  --"是否从卡组盖放？"
		-- 向玩家发送提示信息：选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡在自己场上盖放。
			Duel.SSet(tp,sg)
		end
	end
end
