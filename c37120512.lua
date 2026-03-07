--闇の破神剣
-- 效果：
-- 暗属性的怪兽才能装备。装备的怪兽攻击力上升400，守备力下降200。
function c37120512.initial_effect(c)
	-- 装备魔法卡的发动效果，可以自由连锁，需要选择一个暗属性的怪兽作为装备对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37120512.target)
	e1:SetOperation(c37120512.operation)
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
	-- 暗属性的怪兽才能装备
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c37120512.eqlimit)
	c:RegisterEffect(e4)
end
-- 限制装备对象必须为暗属性怪兽
function c37120512.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 筛选场上正面表示的暗属性怪兽
function c37120512.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 设置效果目标为场上正面表示的暗属性怪兽
function c37120512.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37120512.filter(chkc) end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c37120512.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c37120512.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数，将装备卡装备给目标怪兽
function c37120512.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
