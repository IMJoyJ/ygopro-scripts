--台貫計量
-- 效果：
-- ①：对方场上的怪兽数量比自己场上的怪兽多2只以上的场合才能发动。对方直到自身场上的怪兽变成1只为止必须送去墓地。
function c39103226.initial_effect(c)
	-- 创建效果并设置其分类、类型、发动时机、条件、目标和处理函数
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
-- 判断发动条件：对方场上的怪兽数量比自己场上的怪兽多2只以上
function c39103226.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 计算对方场上的怪兽数量与自己场上的怪兽数量的差值是否大于等于2
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end
-- 设置效果的目标：选择对方场上需要送去墓地的怪兽数量
function c39103226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的怪兽数量
	local mc=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local count=mc-1
	if chk==0 then return count>0 end
	-- 设置连锁操作信息，指定将对方场上的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,count,1-tp,LOCATION_MZONE)
end
-- 处理效果的发动：从对方场上选择怪兽送去墓地
function c39103226.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
	local count=g:GetCount()-1
	if count>0 then
		-- 提示对方选择要送去墓地的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,count,count,nil)
		-- 显示选中的怪兽被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 将选中的怪兽以规则原因送去墓地
		Duel.SendtoGrave(sg,REASON_RULE)
	end
end
