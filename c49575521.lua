--ドラゴンメイド・フルス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
-- ②：只要自己场上有融合怪兽存在，这张卡不会被效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只2星「半龙女仆」怪兽特殊召唤。
function c49575521.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽回到卡组。
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
-- 将自身从手卡丢弃作为费用
function c49575521.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身送入墓地作为发动效果的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断目标是否为怪兽且能返回卡组
function c49575521.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 设置效果目标：选择墓地1只符合条件的怪兽作为对象
function c49575521.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c49575521.tdfilter(chkc) end
	-- 检查是否有满足条件的墓地怪兽可选
	if chk==0 then return Duel.IsExistingTarget(c49575521.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标怪兽并将其设为效果对象
	local g=Duel.SelectTarget(tp,c49575521.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：记录将要返回卡组的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 处理效果执行：将目标怪兽送回卡组
function c49575521.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数：判断是否为表侧表示的融合怪兽
function c49575521.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 条件函数：判断自己场上是否存在融合怪兽
function c49575521.indcon(e)
	-- 检查自己场上是否存在至少1只融合怪兽
	return Duel.IsExistingMatchingCard(c49575521.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断是否为2星半龙女仆怪兽且可特殊召唤
function c49575521.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标：检查是否满足发动条件（返回手卡、有空场、有可特殊召唤的怪兽）
function c49575521.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查自己场上是否有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己手牌中是否存在符合条件的半龙女仆怪兽
		and Duel.IsExistingMatchingCard(c49575521.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：记录将要返回手卡的卡片
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：记录将要特殊召唤的怪兽数量和来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理效果执行：将自身送回手卡并从手卡特殊召唤1只2星半龙女仆怪兽
function c49575521.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身在场且成功送回手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认自身在手牌且场上存在可用怪兽区
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只符合条件的半龙女仆怪兽
		local g=Duel.SelectMatchingCard(tp,c49575521.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
