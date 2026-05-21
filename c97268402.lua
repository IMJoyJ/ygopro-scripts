--エフェクト・ヴェーラー
-- 效果：
-- ①：对方主要阶段，把这张卡从手卡送去墓地，以对方场上1只效果怪兽为对象才能发动。那只对方怪兽的效果直到回合结束时无效。
function c97268402.initial_effect(c)
	-- ①：对方主要阶段，把这张卡从手卡送去墓地，以对方场上1只效果怪兽为对象才能发动。那只对方怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97268402,0))  --"怪兽的效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c97268402.condition)
	e1:SetCost(c97268402.cost)
	e1:SetTarget(c97268402.target)
	e1:SetOperation(c97268402.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件判定函数
function c97268402.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处的阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 定义发动代价（Cost）判定与执行函数
function c97268402.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身从手卡送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义效果发动目标（Target）判定与选择函数
function c97268402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在连锁处理前，重新确认已选择的对象是否仍为对方场上的合法效果怪兽
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 在发动时，判定对方场上是否存在可作为对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择要无效的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择对方场上1只效果怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：无效所选对象的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 定义效果处理（Operation）执行函数
function c97268402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只对方怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
