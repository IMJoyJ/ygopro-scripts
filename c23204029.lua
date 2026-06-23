--C・HERO カオス
-- 效果：
-- 「假面英雄」怪兽×2
-- 这个卡名在规则上也当作「元素英雄」卡使用。这张卡不用融合召唤不能特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用。
-- ②：自己·对方回合1次，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效。
function c23204029.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用2个「假面英雄」卡为融合素材进行融合召唤
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xa008),2,true)
	-- 这张卡不用融合召唤不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡必须通过融合召唤才能特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，这张卡的属性也当作「光」使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	-- 自己·对方回合1次，以场上1张表侧表示卡为对象才能发动。那张卡的效果直到回合结束时无效
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
-- 设置效果目标为场上1张表侧表示卡，且该卡可被无效化
function c23204029.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 设置效果目标为场上1张表侧表示卡，且该卡可被无效化
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在可作为效果对象的场上卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1张表侧表示卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定将要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果，使目标卡的效果无效
function c23204029.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽的效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
