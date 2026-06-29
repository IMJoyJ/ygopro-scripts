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
-- 特召自身需要弹回手卡的自己场上「超级运动员」怪兽的过滤条件
function c11637481.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(11637481) and c:IsAbleToHandAsCost()
		-- 检查在选定怪兽返回手卡后，自己场上是否有空闲的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特召自身特殊召唤规程的发动条件
function c11637481.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在符合过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c11637481.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特召自身选择弹回怪兽的流程
function c11637481.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有符合过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c11637481.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向玩家发送提示，请选择要返回手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特召自身将怪兽弹回手卡的流程
function c11637481.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为特召规程代价的怪兽送回手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 对方主要阶段发动特召效果的阶段条件判断
function c11637481.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是对方回合且正处于主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 可从手卡返回卡组的5星以上「超级运动员」怪兽的过滤条件
function c11637481.spfilter1(c,e,tp)
	return c:IsSetCard(0xb2) and c:IsLevelAbove(5) and c:IsAbleToDeck()
		-- 检查卡组中是否存在另一只不同卡名的「超级运动员」怪兽可供特殊召唤
		and Duel.IsExistingMatchingCard(c11637481.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 可从卡组特殊召唤的不同名「超级运动员」怪兽的过滤条件
function c11637481.spfilter2(c,e,tp,tc)
	return c:IsSetCard(0xb2) and not c:IsCode(tc:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡组特殊召唤效果的发动准备
function c11637481.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域、此卡是否能返回手卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsAbleToHand()
		-- 检查手卡中是否存在满足条件的5星以上「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c11637481.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为将手卡中的1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息为将此卡返回持有者手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 卡组特殊召唤效果的执行
function c11637481.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无空怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示，请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 获取手卡中所有符合过滤条件的怪兽
	local g1=Duel.GetMatchingGroup(c11637481.spfilter1,tp,LOCATION_HAND,0,nil,e,tp)
	if g1:GetCount()<=0 then return end
	-- 向玩家发送提示，请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local tg1=g1:Select(tp,1,1,nil)
	-- 向对方玩家展示即将返回卡组的怪兽
	Duel.ConfirmCards(1-tp,tg1)
	-- 将选中的怪兽返回卡组并洗牌
	if Duel.SendtoDeck(tg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 向玩家发送提示，请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择卡组中1张满足条件的不同名「超级运动员」怪兽
		local g2=Duel.SelectMatchingCard(tp,c11637481.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tg1:GetFirst())
		-- 将选中的怪兽特殊召唤，并且此卡依然与效果关联
		if Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)>0 and e:GetHandler():IsRelateToEffect(e) then
			-- 切断效果处理的连锁时点
			Duel.BreakEffect()
			-- 将场上的此卡送回持有者手卡
			Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		end
	end
end
