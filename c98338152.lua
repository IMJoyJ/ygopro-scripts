--閃刀機－ウィドウアンカー
-- 效果：
-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，自己墓地有魔法卡3张以上存在的场合，可以把那只怪兽的控制权直到结束阶段得到。
function c98338152.initial_effect(c)
	-- ①：自己的主要怪兽区域没有怪兽存在的场合，以场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，自己墓地有魔法卡3张以上存在的场合，可以把那只怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c98338152.condition)
	e1:SetTarget(c98338152.target)
	e1:SetOperation(c98338152.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡片是否在主要怪兽区域（格子序号0-4）。
function c98338152.cfilter(c)
	return c:GetSequence()<5
end
-- 发动条件判定函数：检查自己的主要怪兽区域是否存在怪兽。
function c98338152.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域没有怪兽存在。
	return not Duel.IsExistingMatchingCard(c98338152.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标选择与处理，若墓地有3张以上魔法卡，则追加改变控制权的效果分类。
function c98338152.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果处理前，检查作为对象的目标卡是否仍在主要怪兽区域且是未被无效的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 在效果发动时，检查场上是否存在可以被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家发送提示信息，要求选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家选择场上1只未被无效的效果怪兽作为对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 检查自己墓地是否存在3张以上的魔法卡，若满足则将效果分类追加“改变控制权”。
	if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3 then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_CONTROL)
	end
end
-- 效果处理函数：使目标怪兽效果无效，并根据条件决定是否夺取其控制权。
function c98338152.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该怪兽相关的连锁中已发动的效果无效化。
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
		-- 手动刷新场上受到影响的卡的无效状态。
		Duel.AdjustInstantly()
		-- 检查自己墓地是否有3张以上的魔法卡。
		if Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_SPELL)>=3
			and tc:IsDisabled() and tc:IsControler(1-tp) and tc:IsControlerCanBeChanged()
			-- 若满足条件，询问玩家是否选择获得该怪兽的控制权。
			and Duel.SelectYesNo(tp,aux.Stringid(98338152,0)) then  --"是否获得控制权？"
			-- 中断当前效果处理，使后续的控制权转移与无效化处理不视为同时进行（那之后）。
			Duel.BreakEffect()
			-- 获得该怪兽的控制权直到结束阶段。
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end
