--U.A.リベロスパイカー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让「超级运动员 自由人攻手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：对方主要阶段才能发动。手卡1只5星以上的「超级运动员」怪兽回到卡组，和那只怪兽卡名不同的1只「超级运动员」怪兽从卡组特殊召唤。那之后，场上的这张卡回到持有者手卡。
function c11637481.initial_effect(c)
	-- ①：这张卡可以让「超级运动员 自由人攻手」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
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
	-- ②：对方主要阶段才能发动。手卡1只5星以上的「超级运动员」怪兽回到卡组，和那只怪兽卡名不同的1只「超级运动员」怪兽从卡组特殊召唤。那之后，场上的这张卡回到持有者手卡。
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
-- 过滤函数，用于判断场上是否有满足条件的「超级运动员」怪兽可以送回手卡
function c11637481.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(11637481) and c:IsAbleToHandAsCost()
		-- 检查场上是否有足够的怪兽区域可以进行特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断特殊召唤条件是否满足
function c11637481.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的「超级运动员」怪兽
	return Duel.IsExistingMatchingCard(c11637481.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 设置特殊召唤的目标选择函数
function c11637481.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的「超级运动员」怪兽组
	local g=Duel.GetMatchingGroup(c11637481.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要送回手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的操作函数
function c11637481.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定怪兽送回手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 判断效果发动条件是否满足
function c11637481.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方主要阶段
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤函数，用于判断手卡中是否有满足条件的5星以上「超级运动员」怪兽
function c11637481.spfilter1(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsLevelAbove(5) and c:IsAbleToDeck()
		-- 检查卡组中是否存在满足条件的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c11637481.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 过滤函数，用于判断卡组中是否有满足条件的「超级运动员」怪兽
function c11637481.spfilter2(c,e,tp,tc)
	return c:IsSetCard(0xb2) and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动的目标选择函数
function c11637481.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToHand()
		-- 检查手卡中是否存在满足条件的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c11637481.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：将1张手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：将此卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行效果发动的操作函数
function c11637481.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 获取满足条件的手卡怪兽组
	local g1=Duel.GetMatchingGroup(c11637481.spfilter1,tp,LOCATION_HAND,0,nil,e,tp)
	if g1:GetCount()<=0 then return end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg1=g1:Select(tp,1,1,nil)
	-- 确认玩家选择的怪兽
	Duel.ConfirmCards(1-tp,tg1)
	-- 将指定怪兽送回卡组并洗牌
	if Duel.SendtoDeck(tg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的卡组怪兽
		local g2=Duel.SelectMatchingCard(tp,c11637481.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tg1:GetFirst())
		-- 特殊召唤选定的怪兽并检查此卡是否还在场上
		if Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP) and e:GetHandler():IsRelateToEffect(e) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将此卡送回手卡
			Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		end
	end
end
