--守護神の矛
-- 效果：
-- 装备怪兽的攻击力上升双方墓地存在的和装备怪兽同名的卡数量×900的数值。
function c42709949.initial_effect(c)
	-- 装备怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42709949.target)
	e1:SetOperation(c42709949.operation)
	c:RegisterEffect(e1)
	-- 的攻击力上升双方墓地存在的和装备怪兽同名的卡数量×900的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c42709949.value)
	c:RegisterEffect(e2)
	-- 装备怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 发动时选择场上1只表侧表示怪兽作为装备对象，并登记装备操作信息。
function c42709949.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查发动条件：场上是否存在1只表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只场上表侧表示怪兽，并设为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次效果处理为装备操作，将这张卡装备给对象，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡与对象怪兽仍与效果关联且对象仍表侧表示，则将这张卡装备给对象怪兽。
function c42709949.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽的攻击力上升数值：统计双方墓地中与装备怪兽同名的卡数量，每张上升900。
function c42709949.value(e,c)
	-- 统计双方墓地中与装备怪兽同名的卡的数量，并乘以900作为攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsCode,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,c:GetCode())*900
end
