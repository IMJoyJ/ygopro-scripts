--機甲部隊の超臨界
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只机械族怪兽为对象才能发动。和那只怪兽卡名不同的1只「机甲」怪兽从手卡·卡组特殊召唤，作为对象的怪兽破坏。
-- ②：把墓地的这张卡除外，从自己墓地的怪兽以及除外的自己怪兽之中以3只机械族怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c59741415.initial_effect(c)
	-- ①：以自己场上1只机械族怪兽为对象才能发动。和那只怪兽卡名不同的1只「机甲」怪兽从手卡·卡组特殊召唤，作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59741415,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,59741415)
	e1:SetTarget(c59741415.sptg)
	e1:SetOperation(c59741415.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从自己墓地的怪兽以及除外的自己怪兽之中以3只机械族怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59741415,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,59741415)
	-- 把墓地的这张卡除外作为发动成本（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c59741415.drtg)
	e2:SetOperation(c59741415.drop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的机械族怪兽，且手卡·卡组存在与其卡名不同、可特殊召唤的「机甲」怪兽
function c59741415.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
		-- 检查手卡·卡组是否存在与该怪兽卡名不同的、可特殊召唤的「机甲」怪兽
		and Duel.IsExistingMatchingCard(c59741415.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤手卡·卡组中卡名与指定code不同、且可以特殊召唤的「机甲」怪兽
function c59741415.spfilter(c,e,tp,code)
	return c:IsSetCard(0x36) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（Target），包括检查是否满足发动条件、选择要破坏的场上怪兽作为对象
function c59741415.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59741415.desfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的、可作为对象的机械族怪兽
		and Duel.IsExistingTarget(c59741415.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的机械族怪兽作为对象
	local g=Duel.SelectTarget(tp,c59741415.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置破坏的操作信息（破坏作为对象的怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的效果处理（Operation），特殊召唤「机甲」怪兽并破坏对象怪兽
function c59741415.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetCode()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组选择1只与对象怪兽卡名不同的「机甲」怪兽
		local g=Duel.SelectMatchingCard(tp,c59741415.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,code)
		-- 若成功将选择的「机甲」怪兽以表侧表示特殊召唤
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 破坏作为对象的怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤自己墓地或除外的、可以回到卡组的机械族怪兽
function c59741415.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsRace(RACE_MACHINE) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target），包括检查是否能抽卡、选择3只机械族怪兽作为对象
function c59741415.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c59741415.tdfilter(chkc) end
	-- 检查自己当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地及除外的怪兽中是否存在至少3只满足条件的机械族怪兽
		and Duel.IsExistingTarget(c59741415.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地及除外的怪兽中选择3只机械族怪兽作为对象
	local g=Duel.SelectTarget(tp,c59741415.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	-- 设置返回卡组的操作信息（将选择的3张卡送回卡组）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置抽卡的操作信息（自己从卡组抽1张卡）
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理（Operation），将对象怪兽洗回卡组并抽1张卡
function c59741415.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与当前效果有关联的对象怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将这些对象怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若有卡片成功返回了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果处理，使后续的抽卡处理不与返回卡组同时进行（造成错时点）
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
