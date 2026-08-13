--ドラゴンメイド・フルス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只2星「半龙女仆」怪兽特殊召唤。
function c49575521.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：把这张卡从手卡丢弃，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49575521,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,49575521)
	e1:SetCost(c49575521.tdcost)
	e1:SetTarget(c49575521.tdtg)
	e1:SetOperation(c49575521.tdop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c49575521.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只2星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49575521,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,49575522)
	e3:SetTarget(c49575521.sptg)
	e3:SetOperation(c49575521.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价处理函数：检测并执行将这张卡从手卡丢弃作为发动代价。
function c49575521.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 以代价与丢弃的理由将这张卡从手卡送去墓地，完成①的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 返回真当且仅当卡是怪兽且能够返回卡组，用于筛选①效果的墓地对象。
function c49575521.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ①效果的目标选择函数：检查存在合法对象后，从双方墓地选择1只怪兽为对象，并设置返回卡组的操作信息。
function c49575521.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c49575521.tdfilter(chkc) end
	-- 发动合法性检查：确认双方墓地存在至少1只满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c49575521.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 令玩家从双方墓地选择1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c49575521.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置本次连锁的操作信息：将所选对象返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果处理函数：将效果对象从墓地返回卡组并洗牌。
function c49575521.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果理由返回持有者卡组，因非指定位置而洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 判定怪兽为表侧表示的融合怪兽，用于②效果的抗性条件。
function c49575521.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- ②效果生效的条件：自己场上有表侧表示融合怪兽存在。
function c49575521.indcon(e)
	-- 检查自己场上是否存在至少1只表侧表示融合怪兽。
	return Duel.IsExistingMatchingCard(c49575521.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 筛选特殊召唤对象：持有「半龙女仆」字段、等级为2且能被特殊召唤的手卡怪兽。
function c49575521.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件判定：本卡可回手、场上有空位、手卡有符合条件的「半龙女仆」怪兽。
function c49575521.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查这张卡离开场上后自己是否有可用的怪兽区域。
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的「半龙女仆」怪兽。
		and Duel.IsExistingMatchingCard(c49575521.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：这张卡将返回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：将从手卡特殊召唤1只「半龙女仆」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理函数：这张卡返回手卡成功且仍在手卡、场上有空位时，从手卡特殊召唤1只符合条件的「半龙女仆」怪兽。
function c49575521.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与效果相关，且成功返回手卡。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡已回到手卡，且自己场上仍有可用的怪兽区域。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 令玩家从手卡选择1只符合条件的「半龙女仆」怪兽。
		local g=Duel.SelectMatchingCard(tp,c49575521.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
