--常世離レ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地最多5张卡为对象，并以那个数量的对方的除外状态的卡为对象才能发动。作为对象的墓地的卡除外，作为对象的除外状态的卡回到墓地。
function c11110218.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,11110218+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11110218.target)
	e1:SetOperation(c11110218.activate)
	c:RegisterEffect(e1)
end
-- 效果原文内容：①：以对方墓地最多5张卡为对象，并以那个数量的对方的除外状态的卡为对象才能发动。
function c11110218.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果原文内容：作为对象的墓地的卡除外，作为对象的除外状态的卡回到墓地。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		-- 检索满足条件的对方墓地的卡
		and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,0,LOCATION_REMOVED,1,nil) end
	-- 检索满足条件的对方除外区的卡
	local rt=Duel.GetTargetCount(aux.TRUE,tp,0,LOCATION_REMOVED,nil)
	if rt>5 then rt=5 end
	-- 提示玩家选择除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择最多5张对方墓地的卡作为除外对象
	local g1=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,rt,nil)
	-- 提示玩家选择送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择与上一步选择的除外卡数量相同的对方除外区的卡作为送入墓地对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,0,LOCATION_REMOVED,#g1,#g1,nil)
	-- 设置操作信息：将选择的墓地卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,#g1,0,0)
	-- 设置操作信息：将选择的除外卡送入墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,#g2,0,0)
end
-- 过滤函数：判断卡是否在指定位置且与效果相关
function c11110218.filter(c,loc,e)
	return c:IsLocation(loc) and c:IsRelateToEffect(e)
end
-- 效果处理函数：执行效果的处理逻辑
function c11110218.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg1=g:Filter(c11110218.filter,nil,LOCATION_GRAVE,e)
	local tg2=g:Filter(c11110218.filter,nil,LOCATION_REMOVED,e)
	-- 将对象卡组中位于墓地的卡除外
	if Duel.Remove(tg1,POS_FACEUP,REASON_EFFECT)>0 then
		-- 将对象卡组中位于除外区的卡送入墓地
		Duel.SendtoGrave(tg2,REASON_EFFECT+REASON_RETURN)
	end
end
