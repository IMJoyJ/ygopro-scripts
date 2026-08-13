--闇の破神剣
-- 效果：
-- 暗属性的怪兽才能装备。装备的怪兽攻击力上升400，守备力下降200。
function c37120512.initial_effect(c)
	-- 暗属性的怪兽才能装备。
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
	-- 守备力下降200
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(-200)
	c:RegisterEffect(e3)
	-- 暗属性的怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c37120512.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制的判定函数：检查对象怪兽是否为暗属性，只有暗属性怪兽才能装备此卡。
function c37120512.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 发动时选择对象的筛选条件：场上表侧表示的暗属性怪兽。
function c37120512.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 发动时的取对象处理：从场上表侧表示的暗属性怪兽中选择1只作为装备对象，并设置操作信息。
function c37120512.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37120512.filter(chkc) end
	-- 发动时检查场上是否存在表侧表示的暗属性怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c37120512.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发出选择提示，提示文字为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从符合条件的怪兽中选择1只作为装备对象（取对象）。
	Duel.SelectTarget(tp,c37120512.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡，用于连锁处理和相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡和目标怪兽仍与效果关联且目标为表侧表示，则将此卡装备给目标怪兽。
function c37120512.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
