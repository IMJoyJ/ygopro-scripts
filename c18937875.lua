--灼熱の槍
-- 效果：
-- 炎属性的怪兽才能装备。装备的怪兽攻击力上升400，守备力下降200。
function c18937875.initial_effect(c)
	-- 装备魔法卡的发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c18937875.target)
	e1:SetOperation(c18937875.operation)
	c:RegisterEffect(e1)
	-- 装备的怪兽攻击力上升400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	-- 装备的怪兽守备力下降200
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(-200)
	c:RegisterEffect(e3)
	-- 炎属性的怪兽才能装备
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c18937875.eqlimit)
	c:RegisterEffect(e4)
end
-- 检查目标怪兽是否为炎属性
function c18937875.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 筛选场上正面表示的炎属性怪兽
function c18937875.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 选择装备对象怪兽
function c18937875.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18937875.filter(chkc) end
	-- 判断是否有符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c18937875.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的炎属性怪兽作为装备对象
	Duel.SelectTarget(tp,c18937875.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的处理效果
function c18937875.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
