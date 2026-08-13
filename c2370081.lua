--はがねの甲羅
-- 效果：
-- 水属性怪兽才能装备。装备怪兽的攻击力上升400，守备力下降200。
function c2370081.initial_effect(c)
	-- 水属性怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c2370081.target)
	e1:SetOperation(c2370081.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力下降200。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(-200)
	c:RegisterEffect(e3)
	-- 水属性怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c2370081.eqlimit)
	c:RegisterEffect(e4)
end
-- 判定装备对象是否满足水属性怪兽的装备限制条件。
function c2370081.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选场上表侧表示的水属性怪兽作为可装备对象。
function c2370081.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 发动时的选择处理：从双方场上选择一只表侧表示的水属性怪兽作为装备对象，并设置装备操作信息。
function c2370081.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c2370081.filter(chkc) end
	-- 发动条件检查：确认场上是否存在至少1只符合条件的表侧表示水属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(c2370081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示，要求选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只场上表侧表示的水属性怪兽作为装备对象。
	Duel.SelectTarget(tp,c2370081.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的处理信息，宣告将进行装备卡装备处理。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若装备卡自身仍关联此效果且目标怪兽仍关联且表侧表示，则将装备卡装备给目标怪兽。
function c2370081.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给选择的对象。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
