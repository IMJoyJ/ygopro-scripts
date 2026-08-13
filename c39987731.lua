--脅威の人造人間－サイコ・ショッカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的场上·墓地有陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级直到回合结束时变成6星。
-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从自己的手卡·墓地选1只「人造人-念力震慑者」特殊召唤。那之后，可以把对方场上的陷阱卡全部破坏（那些卡在盖放中的场合，翻开确认）。
function c39987731.initial_effect(c)
	-- 记录本卡效果外文本中提到的「人造人-念力震慑者」（卡号77585513），便于相关检索或判定。
	aux.AddCodeList(c,77585513)
	-- ①：自己或者对方的场上·墓地有陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级直到回合结束时变成6星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39987731,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39987731)
	e1:SetCondition(c39987731.spcon1)
	e1:SetTarget(c39987731.sptg1)
	e1:SetOperation(c39987731.spop1)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从自己的手卡·墓地选1只「人造人-念力震慑者」特殊召唤。那之后，可以把对方场上的陷阱卡全部破坏（那些卡在盖放中的场合，翻开确认）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39987731,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_SSET+TIMING_MAIN_END)
	e2:SetCountLimit(1,39987732)
	e2:SetCondition(c39987731.spcon2)
	e2:SetCost(c39987731.spcost2)
	e2:SetTarget(c39987731.sptg2)
	e2:SetOperation(c39987731.spop2)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：表侧表示或位于墓地的陷阱卡，用于检测场上或墓地是否存在陷阱卡。
function c39987731.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TRAP)
end
-- 效果①的发动条件：检查双方场上或墓地合计是否存在至少1张满足cfilter的陷阱卡。
function c39987731.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 以tp玩家视角，在双方场上和墓地范围内搜索是否存在至少1张满足cfilter的卡。
	return Duel.IsExistingMatchingCard(c39987731.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
end
-- 效果①的发动目标判定：确认己方主怪兽区有空格，且此卡在手牌可以被特殊召唤。
function c39987731.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查己方怪兽区可用空格大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果为特殊召唤效果，对象为效果发动者自身的这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：把这张卡从手卡特殊召唤；若成功，再给它附加等级变为6星直到回合结束的效果。
function c39987731.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果有关联后，将其以表侧表示特殊召唤到己方场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡的等级直到回合结束时变成6星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(6)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 结束特殊召唤的处理流程，完成连锁中的特殊召唤（与SpecialSummonStep配合）。
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件：当前阶段是主要阶段1或主要阶段2（即自己或对方的主要阶段）。
function c39987731.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②的发动代价：解放这张卡，并确认解放后场上仍有可用的怪兽区空间。
function c39987731.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 在代价判定时（chk==0）检查：这张卡可解放，且解放后己方怪兽区仍有至少1个空格。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行解放操作，将这张卡作为代价送入墓地（REASON_COST）。
	Duel.Release(c,REASON_COST)
end
-- 定义特殊召唤候选卡的过滤条件：必须是「人造人-念力震慑者」（卡号77585513），且可以被当前效果特殊召唤。
function c39987731.spfilter(c,e,tp)
	return c:IsCode(77585513) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标判定：确认满足条件的「人造人-念力震慑者」存在于手牌或墓地，并设置操作信息。
function c39987731.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算特殊召唤所需空格：若cost阶段已标记（e:GetLabel()==100）或当前已有空格，则res为真。
	local res=e:GetLabel()==100 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 在chk==0时重置标记，并返回：有空格且手牌·墓地存在可特殊召唤的「人造人-念力震慑者」。
		return res and Duel.IsExistingMatchingCard(c39987731.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置操作信息：从手牌或墓地特殊召唤1只「人造人-念力震慑者」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 定义可破坏目标：对方场上的陷阱卡，或里侧盖放在魔法陷阱区的卡（后者用于翻开确认）。
function c39987731.desfilter(c)
	return c:IsType(TYPE_TRAP) or c39987731.cffilter(c)
end
-- 定义里侧表示且在魔法陷阱区（且非场地魔法格）的卡，用于后续翻开确认。
function c39987731.cffilter(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5
end
-- 效果②处理：选择并特殊召唤1只「人造人-念力震慑者」到场上；成功后再选择是否破坏对方场上全部陷阱卡，如有里侧卡先翻开确认。
function c39987731.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方怪兽区没有空格，则效果处理直接终止（无法特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 给玩家发送选择提示消息，提示正在选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp从自己手卡·墓地中选择1张满足spfilter（且不受王家长眠之谷影响的）「人造人-念力震慑者」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39987731.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若特殊召唤成功，且对方场上有可破坏的陷阱卡，则询问tp是否把对方场上的陷阱卡全部破坏。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(c39987731.desfilter,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(39987731,2)) then  --"是否把对方场上的陷阱卡全部破坏？"
		-- 获取对方场上里侧表示的魔法陷阱区卡（用于翻开确认）。
		local sg=Duel.GetMatchingGroup(c39987731.cffilter,tp,0,LOCATION_ONFIELD,nil)
		-- 若存在里侧卡，则将这些卡展示给tp确认。
		if sg:GetCount()>0 then Duel.ConfirmCards(tp,sg) end
		-- 获取对方场上所有陷阱卡（包含表侧和里侧）。
		local dg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_TRAP)
		if dg:GetCount()>0 then
			-- 中断当前效果处理，使后续的破坏动作不与前面的特殊召唤同时处理（错开时点）。
			Duel.BreakEffect()
			-- 以效果（REASON_EFFECT）破坏dg中的全部陷阱卡。
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
