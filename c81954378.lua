--死神の大鎌－デスサイス
-- 效果：
-- 「守护者·戴思塞斯」才能装备。
-- ①：装备怪兽的攻击力上升双方墓地的怪兽数量×500。
function c81954378.initial_effect(c)
	-- 「守护者·戴思塞斯」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c81954378.target)
	e1:SetOperation(c81954378.operation)
	c:RegisterEffect(e1)
	-- 「守护者·戴思塞斯」才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c81954378.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升双方墓地的怪兽数量×500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c81954378.value)
	c:RegisterEffect(e3)
end
-- 装备限制函数，限制装备卡只能装备给「守护者·戴思塞斯」
function c81954378.eqlimit(e,c)
	return c:IsCode(18175965)
end
-- 过滤函数：场上表侧表示且卡名为「守护者·戴思塞斯」的怪兽
function c81954378.filter(c)
	return c:IsFaceup() and c:IsCode(18175965)
end
-- 效果发动的目标选择与操作信息设置函数
function c81954378.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c81954378.filter(chkc) end
	-- 判断场上是否存在满足过滤条件的、可作为装备对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c81954378.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只满足过滤条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c81954378.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的操作信息为：将自身装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行装备操作
function c81954378.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将自身作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力上升值的函数
function c81954378.value(e,c)
	-- 计算双方墓地的怪兽数量并乘以500，作为攻击力上升的数值
	return Duel.GetMatchingGroupCount(Card.IsType,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,TYPE_MONSTER)*500
end
