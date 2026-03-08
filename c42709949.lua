--守護神の矛
-- 效果：
-- 装备怪兽的攻击力上升双方墓地存在的和装备怪兽同名的卡数量×900的数值。
function c42709949.initial_effect(c)
	-- 装备怪兽的攻击力上升双方墓地存在的和装备怪兽同名的卡数量×900的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42709949.target)
	e1:SetOperation(c42709949.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升双方墓地存在的和装备怪兽同名的卡数量×900的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c42709949.value)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升双方墓地存在的和装备怪兽同名的卡数量×900的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 选择装备对象怪兽
function c42709949.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否满足选择装备对象的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果处理
function c42709949.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算双方墓地同名卡数量并乘以900作为攻击力加成
function c42709949.value(e,c)
	-- 检索双方墓地中的同名卡数量并乘以900
	return Duel.GetMatchingGroupCount(Card.IsCode,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,c:GetCode())*900
end
