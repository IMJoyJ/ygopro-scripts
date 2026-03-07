--ヴェルズ・ゴーレム
-- 效果：
-- 1回合1次，可以选择场上表侧表示存在的1只暗属性以外的5星以上的怪兽破坏。
function c31456110.initial_effect(c)
	-- 效果原文内容：1回合1次，可以选择场上表侧表示存在的1只暗属性以外的5星以上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31456110,0))  --"怪兽破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c31456110.destg)
	e1:SetOperation(c31456110.desop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的怪兽组：表侧表示、非暗属性、等级5以上
function c31456110.filter(c)
	return c:IsFaceup() and c:IsNonAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(5)
end
-- 设置效果的发动条件和目标选择逻辑，判断是否能选择符合条件的怪兽
function c31456110.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31456110.filter(chkc) end
	-- 判断是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31456110.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上符合条件的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c31456110.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，确定要破坏的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果的处理函数，执行破坏操作
function c31456110.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c31456110.filter(tc) then
		-- 将目标怪兽因效果而破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
