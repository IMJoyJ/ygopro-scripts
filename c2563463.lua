--流離のグリフォンライダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「勇者衍生物」存在，魔法·陷阱·怪兽的效果发动时才能发动。这张卡回到持有者卡组，那个发动无效并破坏。
function c2563463.initial_effect(c)
	-- 将「勇者衍生物」的卡号3285552登记到这张卡的效果文本关联代码列表中，用于识别这张卡上记载的「勇者衍生物」卡名，以便后续条件检索。
	aux.AddCodeList(c,3285552)
	-- ①：自己·对方的主要阶段，自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2563463,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2563463)
	e1:SetCondition(c2563463.spcon)
	e1:SetTarget(c2563463.sptg)
	e1:SetOperation(c2563463.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上有「勇者衍生物」存在，魔法·陷阱·怪兽的效果发动时才能发动。场上的这张卡回到卡组，那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2563463,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,2563464)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c2563463.negcon)
	e2:SetTarget(c2563463.negtg)
	e2:SetOperation(c2563463.negop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：卡片必须是卡号3285552（「勇者衍生物」）且为表侧表示。
function c2563463.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- ①效果的发动条件综合判断：仅在主要阶段，且自己场上没有怪兽或存在表侧表示「勇者衍生物」时才能发动。
function c2563463.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2，即自己·对方的主要阶段，否则不能发动。
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 检查自己场上主要怪兽区的怪兽数量是否为0，满足“自己场上没有怪兽存在”的条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 替代条件：检查自己场上是否存在1张以上表侧表示的「勇者衍生物」，满足“有「勇者衍生物」存在”的条件。
		or Duel.IsExistingMatchingCard(c2563463.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的目标与合法性检查：确认自己主要怪兽区有空位，且这张卡自身能够被特殊召唤；若合法则登记特殊召唤自身。
function c2563463.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）先确认自己主要怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁的操作信息：即将把这张卡自身特殊召唤，用于发动后的连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c2563463.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到其持有者（tp）的场上，无视苏生限制和召唤条件。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件综合判断：自己场上有表侧「勇者衍生物」存在，且这张卡未被战斗破坏确定，并且当前连锁可以被无效。
function c2563463.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「勇者衍生物」，若不存在则②效果不能发动。
	if not Duel.IsExistingMatchingCard(c2563463.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	-- 确认这张卡没有处于战斗破坏确定状态，且当前发动的连锁可以被无效化。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- ②效果的目标与合法性检查：确认自身能够回到卡组，然后登记回卡组、无效发动以及可能破坏对方发动卡的操作信息。
function c2563463.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 登记操作信息：将这张卡自身送回卡组，数量1（用于回卡组相关判定）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 登记操作信息：使当前连锁的发动无效，对象为该连锁上发动的卡（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动的那张卡可以被破坏且仍与那个效果关联，则追加登记破坏该卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：若自身仍与效果关联且成功送回卡组洗牌，则无效那次发动；若无效成功且发动卡仍关联，则将其破坏。
function c2563463.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理条件判断：这张卡仍与效果关联，且被送回持有者卡组并洗牌成功，并且最终位于卡组中，才继续执行无效处理。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) then
		-- 真正执行本次连锁发动的无效，且只有对方发动的那张卡仍与效果关联时才继续执行破坏。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将对方发动的那个效果的卡破坏，破坏原因记为效果破坏（REASON_EFFECT）。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
