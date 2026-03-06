--ゲット・アウト！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以从额外卡组特殊召唤的对方场上2只怪兽为对象才能发动。那些怪兽回到持有者卡组。
function c22373487.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
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
-- 规则层面操作：定义过滤函数，用于判断怪兽是否从额外卡组召唤且可以送回卡组。
function c22373487.filter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 规则层面操作：设置效果的目标选择函数，用于选择对方场上的2只从额外卡组特殊召唤的怪兽。
function c22373487.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c22373487.filter(chkc) end
	-- 规则层面操作：检查是否满足选择目标的条件，即对方场上是否存在2只从额外卡组特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c22373487.filter,tp,0,LOCATION_MZONE,2,nil) end
	-- 规则层面操作：向玩家发送提示信息，提示选择要返回卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面操作：选择满足条件的2只对方场上的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c22373487.filter,tp,0,LOCATION_MZONE,2,2,nil)
	-- 规则层面操作：设置连锁的操作信息，表明将要处理2只怪兽送回卡组的效果。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
-- 效果原文内容：①：以从额外卡组特殊召唤的对方场上2只怪兽为对象才能发动。那些怪兽回到持有者卡组。
function c22373487.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁中已选定的目标怪兽，并筛选出与当前效果相关的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 规则层面操作：将符合条件的怪兽送回持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
