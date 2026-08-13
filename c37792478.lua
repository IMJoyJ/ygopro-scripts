--メタボ・シャーク
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的2只鱼族怪兽回到卡组。
function c37792478.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地存在的2只鱼族怪兽回到卡组。
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
-- 筛选条件是鱼族怪兽且能够返回卡组（用于墓地检索候选）
function c37792478.filter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToDeck()
end
-- 处理时筛选对象：必须仍与该效果关联且为鱼族怪兽（防止对象离场后无效）
function c37792478.opfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_FISH)
end
-- 发动时的目标处理：检查是否存在2只符合条件的墓地鱼族，并选择2只作为效果对象，同时设置回卡组的操作信息
function c37792478.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c37792478.filter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少2只满足筛选条件的鱼族怪兽（用于判断是否可发动）
	if chk==0 then return Duel.IsExistingTarget(c37792478.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 给玩家显示“请选择要返回卡组的卡”的选择提示框
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择2只符合条件的鱼族怪兽作为效果对象（取对象）
	local g=Duel.SelectTarget(tp,c37792478.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将本次处理信息设为“回卡组”，对象为所选2张卡，数量为2，便于其他卡进行连锁判定
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理时的操作：取出发动时选择的对象，过滤后若仍存在则全部返回卡组并洗牌
function c37792478.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象，并筛选出仍与该效果关联且为鱼族的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c37792478.opfilter,nil,e)
	if g:GetCount()>0 then
		-- 将筛选后的卡以效果原因送回持有者卡组，并以洗牌方式处理（弹回卡组并洗牌）
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
