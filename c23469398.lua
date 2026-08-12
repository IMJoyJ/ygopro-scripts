--マシンナーズ・エアレイダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：对方回合，以自己场上1只机械族怪兽为对象才能发动。和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽从卡组特殊召唤，作为对象的怪兽破坏。
function c23469398.initial_effect(c)
	-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23469398,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,23469398)
	e1:SetCost(c23469398.spcost1)
	e1:SetTarget(c23469398.sptg1)
	e1:SetOperation(c23469398.spop1)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己场上1只机械族怪兽为对象才能发动。和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽从卡组特殊召唤，作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23469398,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,23469399)
	e2:SetCondition(c23469398.spcon2)
	e2:SetTarget(c23469398.sptg2)
	e2:SetOperation(c23469398.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在满足条件的「机甲」怪兽（必须是怪兽卡、可丢弃）
function c23469398.cfilter(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动时的费用支付处理，丢弃手卡中满足条件的1只「机甲」怪兽
function c23469398.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的「机甲」怪兽（用于费用支付的判定）
	if chk==0 then return Duel.IsExistingMatchingCard(c23469398.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡中满足条件的1只「机甲」怪兽的操作
	Duel.DiscardHand(tp,c23469398.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果发动时的处理，判断是否满足特殊召唤的条件
function c23469398.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果发动时的处理，将此卡特殊召唤到场上
function c23469398.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行将此卡特殊召唤到场上的操作
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果发动的条件判断，判断是否为对方回合
function c23469398.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于判断场上是否存在满足条件的机械族怪兽（必须正面表示、是机械族、且卡组中存在符合条件的「机甲」怪兽）
function c23469398.desfilter(c,e,tp)
	-- 判断目标怪兽是否正面表示、是否为机械族、且卡组中存在符合条件的「机甲」怪兽
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(c23469398.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode(),c:GetLevel())
end
-- 过滤函数，用于判断卡组中是否存在满足条件的「机甲」怪兽（必须是「机甲」卡、卡名不同、等级不超过目标怪兽等级）
function c23469398.spfilter(c,e,tp,code,lv)
	return c:IsSetCard(0x36) and not c:IsCode(code) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，判断是否满足特殊召唤和破坏的条件
function c23469398.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23469398.desfilter(chkc,e,tp) end
	-- 检查场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的机械族怪兽作为对象
		and Duel.IsExistingTarget(c23469398.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的机械族怪兽作为对象
	local g=Duel.SelectTarget(tp,c23469398.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，表示将要从卡组特殊召唤「机甲」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置连锁操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理，选择目标怪兽并特殊召唤符合条件的「机甲」怪兽，随后破坏目标怪兽
function c23469398.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查场上是否有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的「机甲」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的「机甲」怪兽
		local g=Duel.SelectMatchingCard(tp,c23469398.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode(),tc:GetLevel())
		-- 判断是否成功特殊召唤了怪兽，并执行后续处理
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 执行破坏目标怪兽的操作
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
