--メタボ・シャーク
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的2只鱼族怪兽回到卡组。
function c37792478.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37792478,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c37792478.target)
	e1:SetOperation(c37792478.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足鱼族且可以送入卡组的怪兽
function c37792478.filter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToDeck()
end
-- 筛选与效果相关且属于鱼族的怪兽
function c37792478.opfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_FISH)
end
-- 选择2只自己墓地的鱼族怪兽作为效果对象
function c37792478.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c37792478.filter(chkc) end
	-- 检查自己墓地是否存在2只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c37792478.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2只自己墓地的鱼族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37792478.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理时要送入卡组的怪兽数量为2
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 将选中的怪兽送入卡组
function c37792478.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中已选定的效果对象，并筛选出满足条件的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c37792478.opfilter,nil,e)
	if g:GetCount()>0 then
		-- 将满足条件的怪兽以洗牌方式送入卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
