--ブレイクスルー・スキル
-- 效果：
-- ①：以对方场上1只效果怪兽为对象才能发动。那只对方怪兽的效果直到回合结束时无效。
-- ②：自己回合把墓地的这张卡除外，以对方场上1只效果怪兽为对象才能发动。那只对方的效果怪兽的效果直到回合结束时无效。这个效果在这张卡送去墓地的回合不能发动。
function c78474168.initial_effect(c)
	-- ①：以对方场上1只效果怪兽为对象才能发动。那只对方怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c78474168.target)
	e1:SetOperation(c78474168.activate)
	c:RegisterEffect(e1)
	-- ②：自己回合把墓地的这张卡除外，以对方场上1只效果怪兽为对象才能发动。那只对方的效果怪兽的效果直到回合结束时无效。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78474168,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c78474168.negcon)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c78474168.target)
	e2:SetOperation(c78474168.activate2)
	c:RegisterEffect(e2)
end
-- 效果①和②的选择对象阶段，用于确认和选择对方场上1只未被无效的效果怪兽
function c78474168.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在连锁处理时，检查已选择的对象是否仍是对方场上未被无效的效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 在发动效果时，检查对方场上是否存在至少1只可以被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端向玩家发送提示信息，要求选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只未被无效的效果怪兽作为效果的对象
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果①的发动处理：使作为对象的对方怪兽的效果直到回合结束时无效
function c78474168.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
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
-- 效果②的发动条件：必须在自己回合，且不能在送去墓地的回合发动
function c78474168.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合，且这张卡不是在当前回合送去墓地
	return aux.exccon(e) and Duel.GetTurnPlayer()==tp
end
-- 效果②的发动处理：使作为对象的对方怪兽的效果直到回合结束时无效
function c78474168.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsType(TYPE_EFFECT) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只对方的效果怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只对方的效果怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
