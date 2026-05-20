--シャイン・キャッスル
-- 效果：
-- 光属性怪兽才能装备。
-- ①：装备怪兽的攻击力上升700。
function c82878489.initial_effect(c)
	-- 光属性怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c82878489.target)
	e1:SetOperation(c82878489.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 光属性怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c82878489.eqlimit)
	c:RegisterEffect(e4)
end
-- 定义装备限制，规定只有光属性怪兽才能装备此卡
function c82878489.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 过滤场上表侧表示的光属性怪兽
function c82878489.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 装备魔法卡发动时的目标选择与效果处理，选择场上1只表侧表示的光属性怪兽作为对象
function c82878489.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c82878489.filter(chkc) end
	-- 在发动准备阶段，检测场上是否存在符合装备条件（表侧表示且为光属性）的怪兽
	if chk==0 then return Duel.IsExistingTarget(c82878489.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只符合条件的怪兽作为当前效果的对象
	Duel.SelectTarget(tp,c82878489.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明将进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，将此卡装备给选择的对象怪兽
function c82878489.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
