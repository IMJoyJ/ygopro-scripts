--ゲット・アウト！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以从额外卡组特殊召唤的对方场上2只怪兽为对象才能发动。那些怪兽回到持有者卡组。
function c22373487.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以从额外卡组特殊召唤的对方场上2只怪兽为对象才能发动。那些怪兽回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22373487+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c22373487.target)
	e1:SetOperation(c22373487.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：对象必须是曾从额外卡组特殊召唤的怪兽，且能够被送回持有者卡组。
function c22373487.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 效果发动时的目标处理：先检查是否存在合法对象，再选择对方场上2只满足条件的怪兽为对象，并设置回卡组的处理信息。
function c22373487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c22373487.filter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少2只满足条件且可以作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22373487.filter,tp,0,LOCATION_MZONE,2,nil) end
	-- 弹出选择提示，提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方场上选择2只满足条件的怪兽作为效果对象，并自动将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c22373487.filter,tp,0,LOCATION_MZONE,2,2,nil)
	-- 登记本次连锁的处理信息：将所选的2张卡以回卡组的效果类别进行处理，供后续时点与效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果处理阶段：取出连锁中记录的对象，过滤出仍与该效果关联的卡，并将它们送回持有者卡组。
function c22373487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象，并筛选出仍然与本次效果存在关联的卡（若对象已离场或失效则排除）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的对象以效果原因送回持有者卡组，并洗切卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
