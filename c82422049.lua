--ガスタへの祈り
-- 效果：
-- 选择自己墓地存在的2只名字带有「薰风」的怪兽，加入卡组洗切。那之后，选择自己墓地存在的1只名字带有「薰风」的怪兽特殊召唤。
function c82422049.initial_effect(c)
	-- 选择自己墓地存在的2只名字带有「薰风」的怪兽，加入卡组洗切。那之后，选择自己墓地存在的1只名字带有「薰风」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c82422049.target)
	e1:SetOperation(c82422049.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中名字带有「薰风」且能回到卡组的怪兽
function c82422049.filter1(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤自己墓地中名字带有「薰风」且能特殊召唤，并且在排除自身后墓地还存在另外2只「薰风」怪兽的卡
function c82422049.filter2(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判定自己墓地是否存在除当前卡以外的2只名字带有「薰风」且能回到卡组的怪兽
		and Duel.IsExistingTarget(c82422049.filter1,tp,LOCATION_GRAVE,0,2,c)
end
-- 效果发动时的对象选择与合法性检测
function c82422049.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以作为特殊召唤对象的「薰风」怪兽
		and Duel.IsExistingTarget(c82422049.filter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只名字带有「薰风」的怪兽作为特殊召唤的对象
	local g1=Duel.SelectTarget(tp,c82422049.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地2只名字带有「薰风」的怪兽（排除特殊召唤的对象）作为返回卡组的对象
	local g2=Duel.SelectTarget(tp,c82422049.filter1,tp,LOCATION_GRAVE,0,2,2,g1:GetFirst())
	-- 设置连锁信息，表示该效果包含将选择的2张卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,2,0,0)
	-- 设置连锁信息，表示该效果包含将选择的1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 效果处理的执行函数
function c82422049.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要返回卡组的对象卡片组
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	-- 获取要特殊召唤的对象卡片组
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	if g1:GetFirst():IsRelateToEffect(e) and g1:GetNext():IsRelateToEffect(e) then
		-- 将选择的2只怪兽送回卡组并洗牌
		Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if g2:GetFirst():IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的特殊召唤处理不与返回卡组同时进行
			Duel.BreakEffect()
			-- 将选择的1只怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
