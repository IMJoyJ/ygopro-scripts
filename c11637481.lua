--U.A.リベロスパイカー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让「超级运动员 自由人攻手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：对方主要阶段才能发动。手卡1只5星以上的「超级运动员」怪兽回到卡组，和那只怪兽卡名不同的1只「超级运动员」怪兽从卡组特殊召唤。那之后，场上的这张卡回到持有者手卡。
function c11637481.initial_effect(c)
	-- ①：这张卡可以让「超级运动员 自由人攻手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。（这个卡名的①的方法的特殊召唤1回合只能有1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11637481,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,11637481+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c11637481.spcon)
	e1:SetTarget(c11637481.sptg)
	e1:SetOperation(c11637481.spop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。手卡1只5星以上的「超级运动员」怪兽回到卡组，和那只怪兽卡名不同的1只「超级运动员」怪兽从卡组特殊召唤。那之后，场上的这张卡回到持有者手卡。（②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11637481,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,11637482)
	e2:SetCondition(c11637481.spcon2)
	e2:SetTarget(c11637481.sptg2)
	e2:SetOperation(c11637481.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上表侧表示的、「超级运动员 自由人攻手」以外的「超级运动员」怪兽中，可以回到手卡作为代价的卡
function c11637481.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(11637481) and c:IsAbleToHandAsCost()
		-- 并且确认该卡离场后自己场上还有空的主要怪兽区可供这张卡特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果特殊召唤的适用条件：检查是否满足特殊召唤条件
function c11637481.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 自己怪兽区存在至少1只满足spfilter条件（可以回到手卡的「超级运动员」怪兽）的卡
	return Duel.IsExistingMatchingCard(c11637481.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- ①效果特殊召唤的处理目标：让玩家选择1只要回到手卡的「超级运动员」怪兽
function c11637481.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己场上所有满足条件的可以回到手卡的「超级运动员」怪兽组
	local g=Duel.GetMatchingGroup(c11637481.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向玩家提示「请选择要返回手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- ①效果的处理：把选择的怪兽回到手卡，完成从手卡的特殊召唤
function c11637481.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 把选择的怪兽以特殊召唤的原因送去持有者的手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果的发动条件：判断是否处于对方的主要阶段
function c11637481.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己，且当前阶段是主要阶段1或主要阶段2（即对方的主要阶段）
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤函数：筛选手卡中5星以上、可以回到卡组的「超级运动员」怪兽
function c11637481.spfilter1(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsLevelAbove(5) and c:IsAbleToDeck()
		-- 并且卡组中存在与该卡卡名不同、可以特殊召唤的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c11637481.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤函数：筛选卡组中「超级运动员」怪兽里，与指定怪兽卡名不同且可以特殊召唤的卡
function c11637481.spfilter2(c,e,tp,tc)
	return c:IsSetCard(0xb2) and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动检测与操作信息设置
function c11637481.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：自己怪兽区有空位且这张卡可以回到手卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToHand()
		-- 并且手卡存在至少1只满足spfilter1条件的5星以上「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c11637481.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：预计把1张手卡中的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：预计从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：预计把这张卡自身回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理：选择手卡1只5星以上「超级运动员」怪兽回到卡组，从卡组特殊召唤卡名不同的「超级运动员」怪兽，然后把这张卡回到手卡
function c11637481.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时如果自己怪兽区没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示「请选择要返回卡组的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 取得手卡中所有满足条件的5星以上「超级运动员」怪兽组
	local g1=Duel.GetMatchingGroup(c11637481.spfilter1,tp,LOCATION_HAND,0,nil,e,tp)
	if g1:GetCount()<=0 then return end
	-- 向玩家提示「请选择要返回卡组的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local tg1=g1:Select(tp,1,1,nil)
	-- 把选择的怪兽给对方确认（因其从手卡离场）
	Duel.ConfirmCards(1-tp,tg1)
	-- 把选择的怪兽洗回卡组，确认成功回到卡组后继续处理
	if Duel.SendtoDeck(tg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 向玩家提示「请选择要特殊召唤的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只与回到卡组的怪兽卡名不同的可以特殊召唤的「超级运动员」怪兽
		local g2=Duel.SelectMatchingCard(tp,c11637481.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tg1:GetFirst())
		-- 将选择的怪兽表侧表示特殊召唤，成功且这张卡仍与这个效果关联时继续处理
		if Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetHandler():IsRelateToEffect(e) then
			-- 中断当前效果处理，使之后的回手处理与特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 把场上的这张卡回到持有者手卡
			Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		end
	end
end
