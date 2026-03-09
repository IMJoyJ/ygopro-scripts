--ヘル・アライアンス
-- 效果：
-- 场上每有1只表侧表示存在的和装备怪兽同名的怪兽，装备怪兽攻击力上升800。
function c46910446.initial_effect(c)
	-- 效果原文：场上每有1只表侧表示存在的和装备怪兽同名的怪兽，装备怪兽攻击力上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46910446.target)
	e1:SetOperation(c46910446.operation)
	c:RegisterEffect(e1)
	-- 效果原文：场上每有1只表侧表示存在的和装备怪兽同名的怪兽，装备怪兽攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c46910446.value)
	c:RegisterEffect(e2)
	-- 效果原文：场上每有1只表侧表示存在的和装备怪兽同名的怪兽，装备怪兽攻击力上升800。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 选择一个场上的表侧表示怪兽作为装备对象。
function c46910446.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件，即场上是否存在至少一只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要装备的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从场上选择一只表侧表示的怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁操作的信息为装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备怪兽并将其装备到选定的目标怪兽上。
function c46910446.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤函数，用于判断一张表侧表示的怪兽是否与指定编号相同。
function c46910446.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 计算场上满足条件的同名怪兽数量，并乘以800作为攻击力加成值。
function c46910446.value(e,c)
	-- 返回场上满足条件的同名怪兽数量乘以800的结果
	return Duel.GetMatchingGroupCount(c46910446.filter,0,LOCATION_MZONE,LOCATION_MZONE,c,c:GetCode())*800
end
