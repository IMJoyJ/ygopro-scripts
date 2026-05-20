--灰滅の復燃
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：让「灰灭的复燃」以外的自己的墓地·除外状态的1张「灰灭」卡回到卡组最下面，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册卡片效果：此卡在1回合只能发动1张，作为魔法/陷阱卡发动，自由时点，需要取对象，有发动代价、效果目标和操作处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：让「灰灭的复燃」以外的自己的墓地·除外状态的1张「灰灭」卡回到卡组最下面，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选除「灰灭的复燃」以外的、自己墓地或除外状态的、表侧表示的「灰灭」卡片，且该卡片能作为代价返回卡组。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1ad) and not c:IsCode(id) and c:IsAbleToDeckAsCost()
end
-- 发动代价处理函数：检查并让玩家选择自己墓地或除外状态的1张「灰灭」卡回到卡组最下面。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地或除外状态是否存在至少1张满足过滤条件的「灰灭」卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1张自己墓地或除外状态的、满足过滤条件的「灰灭」卡片。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 为选择的卡片显示被选为对象的动画效果。
	Duel.HintSelection(g)
	-- 将选择的卡片作为发动代价送回持有者卡组的最下面。
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果目标处理函数：检查并让玩家选择对方场上1只表侧表示的效果怪兽作为对象，并设置效果无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果处理前，检查作为对象的卡片是否仍存在于怪兽区、由对方控制且是未被无效化的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在至少1只表侧表示的、未被无效化的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只表侧表示的、未被无效化的效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：此效果包含使卡片效果无效的操作，操作对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理函数：使作为对象的怪兽的效果直到回合结束时无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
		-- 使与该怪兽相关的连锁中已发动的效果无效化（若该怪兽变为里侧表示则重置）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
