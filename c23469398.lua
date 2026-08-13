--マシンナーズ・エアレイダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：对方回合，以自己场上1只机械族怪兽为对象才能发动。和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽从卡组特殊召唤，作为对象的怪兽破坏。
function c23469398.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
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
-- 筛选条件：是「机甲」系列且为怪兽卡，并且可以作为代价丢弃。
function c23469398.cfilter(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 代价处理：检查手牌存在可丢弃的「机甲」怪兽后，选择并丢弃1张（除自身外）作为发动代价。
function c23469398.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认手牌中存在至少1张除自身外可作为代价丢弃的「机甲」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c23469398.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行丢弃：从手卡丢弃1张符合条件的「机甲」怪兽，丢弃原因同时标记为代价与丢弃。
	Duel.DiscardHand(tp,c23469398.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果的目标阶段：检查主要怪兽区空位及自身可否特殊召唤，并设置特殊召唤的操作信息。
function c23469398.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将自身特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若自身仍与效果关联，则以表侧表示特殊召唤自身。
function c23469398.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将自身以表侧表示特殊召唤到自己的主要怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：当前回合必须是对方回合。
function c23469398.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方（1-tp 即对手）。
	return Duel.GetTurnPlayer()==1-tp
end
-- 选择对象的过滤条件：表侧表示、机械族，并且卡组中存在可特殊召唤且满足条件的「机甲」怪兽。
function c23469398.desfilter(c,e,tp)
	-- 对象需表侧表示且为机械族，同时卡组中存在与对象卡名不同、等级不超过对象的「机甲」怪兽可被特殊召唤。
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(c23469398.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode(),c:GetLevel())
end
-- 卡组中可特招的「机甲」怪兽条件：属于「机甲」系列、与对象卡名不同、等级不大于对象、且能被效果特殊召唤。
function c23469398.spfilter(c,e,tp,code,lv)
	return c:IsSetCard(0x36) and not c:IsCode(code) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标阶段：选择自己场上1只表侧机械族怪兽为对象，并检查空位和对象合法性，同时设置操作信息。
function c23469398.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23469398.desfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的机械族怪兽可以作为取对象的目标。
		and Duel.IsExistingTarget(c23469398.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择自己场上1只满足条件的机械族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c23469398.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果包含从自己卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：本次效果包含破坏对象怪兽（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：若对象仍相关且表侧，则从卡组选择并特殊召唤1只符合条件的「机甲」怪兽；若成功特招则破坏对象。
function c23469398.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果连锁中选择的机械族对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若自己主要怪兽区没有可用空格，则本次效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「机甲」怪兽（与对象卡名不同、等级不超过对象）。
		local g=Duel.SelectMatchingCard(tp,c23469398.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode(),tc:GetLevel())
		-- 若已选择怪兽且特殊召唤成功，则继续执行破坏；否则不破坏。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 以效果原因将对象怪兽破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
