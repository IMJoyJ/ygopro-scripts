--C・HERO カオス
-- 效果：
-- 「假面英雄」怪兽×2
-- 这个卡名在规则上也当作「元素英雄」卡使用。这张卡不用融合召唤不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用。
-- ②：自己·对方回合1次，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
function c23204029.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡注册融合召唤手续：以2只「假面英雄」字段（setcode 0xa008）的怪兽为融合素材进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa008),2,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的值设为aux.fuslimit，使这张卡仅可通过融合召唤特殊召唤，其他方式不能特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合1次，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23204029,0))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1)
	e3:SetTarget(c23204029.target)
	e3:SetOperation(c23204029.operation)
	c:RegisterEffect(e3)
end
c23204029.material_setcode=0x8
-- 效果②的发动条件和选对象处理：确认场上存在可无效的正面卡，让玩家选择1张作为对象，并登记无效化处理信息。
function c23204029.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查待确认对象是否合法：必须在场上，且经aux.NegateAnyFilter判定为可以被无效的卡。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动时检查：双方场上是否存在至少1张可以被无效的表侧表示卡，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向当前玩家显示选择提示「请选择要无效的卡」，供选对象时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从双方场上选择1张满足无效化条件的表侧表示卡，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：本次处理将无效化1张卡（目标为已选对象），供其他效果正确响应。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②的结算流程：取得对象卡，确认其仍正面表示、与效果关联且能被无效后，将其相关连锁无效化，并给它施加直到回合结束时无效的效果；若对象是陷阱怪兽则追加无效其怪兽化效果。
function c23204029.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡相关的连锁无效化，该无效化状态在目标变成里侧表示时被重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
