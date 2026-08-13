--エルフの光
-- 效果：
-- 光属性的怪兽才能装备。装备的怪兽攻击力上升400，守备力下降200。
function c39897277.initial_effect(c)
	-- 光属性的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c39897277.target)
	e1:SetOperation(c39897277.operation)
	c:RegisterEffect(e1)
	-- 装备的怪兽攻击力上升400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	-- 守备力下降200
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(-200)
	c:RegisterEffect(e3)
	-- 光属性的怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c39897277.eqlimit)
	c:RegisterEffect(e4)
end
-- 判断装备对象是否满足装备限制：只有光属性怪兽才能装备这张卡。
function c39897277.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤条件：表侧表示且光属性的怪兽。
function c39897277.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 发动时的目标选择处理：选择场上1只表侧表示的光属性怪兽作为装备对象，并设置装备操作信息。
function c39897277.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c39897277.filter(chkc) end
	-- 发动前检查：是否存在至少1只符合条件的表侧表示光属性怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c39897277.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择“要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从符合条件的怪兽中选择1只，并将其登记为这张卡的效果对象。
	Duel.SelectTarget(tp,c39897277.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息：本次处理为装备这张卡，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的操作：若这张卡和目标怪兽仍与效果关联，且目标怪兽仍表侧表示，则将这张卡装备给目标怪兽。
function c39897277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时所选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
