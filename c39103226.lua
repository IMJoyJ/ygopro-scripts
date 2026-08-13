--台貫計量
-- 效果：
-- ①：对方场上的怪兽数量比自己场上的怪兽多2只以上的场合才能发动。对方直到自身场上的怪兽变成1只为止必须送去墓地。
function c39103226.initial_effect(c)
	-- ①：对方场上的怪兽数量比自己场上的怪兽多2只以上的场合才能发动。对方直到自身场上的怪兽变成1只为止必须送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c39103226.condition)
	e1:SetTarget(c39103226.target)
	e1:SetOperation(c39103226.operation)
	c:RegisterEffect(e1)
end
-- 发动条件函数：判断对方场上的怪兽数量是否比自己场上的怪兽多2只以上，满足才可发动。
function c39103226.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 计算对方场上的怪兽数量减去自己场上的怪兽数量，差值大于等于2则条件成立。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end
-- 发动时目标处理：计算对方场上需要送去墓地的怪兽数量（使其只剩1只），并设置本次效果的操作信息。
function c39103226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上当前存在的怪兽数量，作为计算需要送去墓地数量的基准。
	local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local count=mc-1
	if chk==0 then return count>0 end
	-- 设置操作信息：本次效果涉及不取对象的送去墓地，数量为count，对象为对方场上的怪兽区域。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,count,1-tp,LOCATION_MZONE)
end
-- 效果处理函数：从对方场上的所有怪兽中，由对方选择（总怪兽数-1）只送去墓地，使其场上只剩1只怪兽。
function c39103226.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前存在的所有怪兽，组成集合g。
	local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
	local count=g:GetCount()-1
	if count>0 then
		-- 向对方玩家显示选择提示，要求选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,count,count,nil)
		-- 显示被选中的卡片的选中动画，并将这些卡记录为本次效果涉及的卡。
		Duel.HintSelection(sg)
		-- 将选中的卡以规则效果（REASON_RULE）送去墓地。
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
