--流離のグリフォンライダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「勇者衍生物」存在，魔法·陷阱·怪兽的效果发动时才能发动。这张卡回到持有者卡组，那个发动无效并破坏。
function c2563463.initial_effect(c)
	-- 记录此卡具有「勇者衍生物」的卡名信息
	aux.AddCodeList(c,3285552)
	-- ①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
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
	-- ②：自己场上有「勇者衍生物」存在，魔法·陷阱·怪兽的效果发动时才能发动。这张卡回到持有者卡组，那个发动无效并破坏。
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
-- 定义过滤器函数，用于判断场上是否存在正面表示的「勇者衍生物」
function c2563463.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 效果①的发动条件判断函数，判断是否处于主要阶段且满足召唤条件
function c2563463.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于主要阶段1或主要阶段2
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判断自己场上是否存在「勇者衍生物」
		or Duel.IsExistingMatchingCard(c2563463.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动时的处理函数，判断是否可以特殊召唤
function c2563463.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的连锁信息，确定将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数，执行特殊召唤操作
function c2563463.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件判断函数，判断是否满足发动条件
function c2563463.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在「勇者衍生物」
	if not Duel.IsExistingMatchingCard(c2563463.cfilter,tp,LOCATION_ONFIELD,0,1,nil) then return false end
	-- 判断此卡未因战斗破坏且该连锁可被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果②的发动时的处理函数，设置连锁信息
function c2563463.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置效果处理时的连锁信息，确定将要将此卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
	-- 设置效果处理时的连锁信息，确定将要使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理时的连锁信息，确定将要破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的发动处理函数，执行将此卡送回卡组并使发动无效和破坏
function c2563463.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍存在于场上且成功送回卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) then
		-- 判断是否成功使连锁发动无效且被破坏的卡仍有效
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 执行将发动的卡破坏
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
