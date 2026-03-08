--脅威の人造人間－サイコ・ショッカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的场上·墓地有陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的等级直到回合结束时变成6星。
-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从自己的手卡·墓地选1只「人造人-念力震慑者」特殊召唤。那之后，可以把对方场上的陷阱卡全部破坏（那些卡在盖放中的场合，翻开确认）。
function c39987731.initial_effect(c)
	-- 记录此卡与「人造人-念力震慑者」的关联
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
-- 过滤函数，用于判断场上或墓地是否存在陷阱卡
function c39987731.cfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_TRAP)
end
-- 效果①的发动条件：场上或墓地存在陷阱卡
function c39987731.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上或墓地是否存在至少1张陷阱卡
	return Duel.IsExistingMatchingCard(c39987731.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
end
-- 效果①的发动时点处理：判断是否满足特殊召唤条件
function c39987731.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标玩家场上是否有空怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将此卡加入特殊召唤的处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理：将此卡特殊召唤并变更等级为6
function c39987731.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否还在场上且满足特殊召唤条件
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置等级变更效果：使此卡等级变为6
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(6)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件：当前为自己的主要阶段
function c39987731.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②的发动费用：解放此卡
function c39987731.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	local c=e:GetHandler()
	-- 判断此卡是否可以被解放且目标玩家有空怪兽区
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行解放操作
	Duel.Release(c,REASON_COST)
end
-- 过滤函数，用于筛选「人造人-念力震慑者」
function c39987731.spfilter(c,e,tp)
	return c:IsCode(77585513) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时点处理：判断是否满足特殊召唤条件
function c39987731.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件（包括标签状态或有空怪兽区）
	local res=e:GetLabel()==100 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 检查手牌或墓地是否存在至少1张「人造人-念力震慑者」
		return res and Duel.IsExistingMatchingCard(c39987731.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置效果处理信息：将特殊召唤的「人造人-念力震慑者」加入处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤函数，用于判断是否为陷阱卡或盖放中的魔陷
function c39987731.desfilter(c)
	return c:IsType(TYPE_TRAP) or c39987731.cffilter(c)
end
-- 过滤函数，用于判断是否为盖放中的魔陷
function c39987731.cffilter(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_SZONE) and c:GetSequence()~=5
end
-- 效果②的发动处理：特殊召唤「人造人-念力震慑者」并破坏对方陷阱卡
function c39987731.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断目标玩家是否还有空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的「人造人-念力震慑者」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「人造人-念力震慑者」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39987731.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 判断是否满足发动效果的全部条件（特殊召唤成功、存在陷阱卡、玩家确认破坏）
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(c39987731.desfilter,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(39987731,2)) then  --"是否把对方场上的陷阱卡全部破坏？"
		-- 获取对方场上的盖放陷阱卡
		local sg=Duel.GetMatchingGroup(c39987731.cffilter,tp,0,LOCATION_ONFIELD,nil)
		-- 确认对方场上的盖放陷阱卡
		if sg:GetCount()>0 then Duel.ConfirmCards(tp,sg) end
		-- 获取对方场上的所有陷阱卡
		local dg=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_TRAP)
		if dg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏对方场上的陷阱卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
