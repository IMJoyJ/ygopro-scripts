--超越竜メテオロス
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方回合才能发动。选这张卡以外的自己的手卡·场上2只恐龙族怪兽破坏，这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1只恐龙族怪兽送去墓地。
-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
function c31241087.initial_effect(c)
	-- 设置此卡的特殊召唤条件为只能通过卡的效果特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c31241087.splimit)
	c:RegisterEffect(e0)
	-- ①：对方回合才能发动。选这张卡以外的自己的手卡·场上2只恐龙族怪兽破坏，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31241087,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,31241087)
	e1:SetCondition(c31241087.dspcon)
	e1:SetTarget(c31241087.dsptg)
	e1:SetOperation(c31241087.dspop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把1只恐龙族怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31241087,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,31241088)
	e2:SetTarget(c31241087.tgtg)
	e2:SetOperation(c31241087.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31241087,2))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,31241089)
	e3:SetTarget(c31241087.tdtg)
	e3:SetOperation(c31241087.tdop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件判断函数，只有通过效果才能特殊召唤
function c31241087.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 效果发动条件判断函数，判断是否为对方回合
function c31241087.dspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为发动者
	return Duel.GetTurnPlayer()~=tp
end
-- 破坏效果的过滤函数，筛选恐龙族且表侧表示的怪兽
function c31241087.desfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsFaceupEx()
end
-- 效果发动时的处理函数，设置操作信息，包括特殊召唤和破坏
function c31241087.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取满足条件的怪兽组，包括手牌和场上的恐龙族怪兽
	local g=Duel.GetMatchingGroup(c31241087.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	-- 检查是否满足特殊召唤条件，即是否有2只恐龙族怪兽且有足够怪兽区
	if chk==0 then return g:CheckSubGroup(aux.mzctcheck,2,2,tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息，表示将要破坏2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果发动时的处理函数，执行破坏和特殊召唤
function c31241087.dspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足条件的怪兽组，包括手牌和场上的恐龙族怪兽
	local g=Duel.GetMatchingGroup(c31241087.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,c)
	-- 检查是否满足特殊召唤条件，即是否有2只恐龙族怪兽且有足够怪兽区
	if #g==0 or not g:CheckSubGroup(aux.mzctcheck,2,2,tp) then return end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从满足条件的怪兽组中选择2只怪兽
	local dg=g:SelectSubGroup(tp,aux.mzctcheck,false,2,2,tp)
	-- 显示被选中的怪兽
	Duel.HintSelection(dg)
	-- 执行破坏操作，若失败或此卡无效则返回
	if Duel.Destroy(dg,REASON_EFFECT)==0 or not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果发动时的过滤函数，筛选可以送去墓地的恐龙族怪兽
function c31241087.tgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
-- 效果发动时的处理函数，设置操作信息，表示将要送去墓地
function c31241087.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否卡组中存在满足条件的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31241087.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行送去墓地操作
function c31241087.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c31241087.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果发动时的过滤函数，筛选可以返回卡组的通常怪兽
function c31241087.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 效果发动时的处理函数，设置操作信息，表示将要返回卡组
function c31241087.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否墓地中存在满足条件的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31241087.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表示将要返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	end
end
-- 效果发动时的处理函数，执行返回卡组和特殊召唤
function c31241087.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从墓地中选择1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,c31241087.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		-- 将选中的怪兽返回卡组
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0
			-- 检查此卡是否有效且场上是否有足够怪兽区
			and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 询问玩家是否要特殊召唤此卡
			and Duel.SelectYesNo(tp,aux.Stringid(31241087,3)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将此卡特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
