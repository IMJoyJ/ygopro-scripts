--サラマンドラ
-- 效果：
-- 炎属性怪兽才能装备。
-- ①：装备怪兽的攻击力上升700。
function c32268901.initial_effect(c)
	-- ①：装备怪兽的攻击力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c32268901.target)
	e1:SetOperation(c32268901.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 炎属性怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c32268901.eqlimit)
	c:RegisterEffect(e4)
end
-- 检查目标怪兽是否为炎属性，用于限制装备对象
function c32268901.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 筛选场上表侧表示的炎属性怪兽，作为装备对象的过滤条件
function c32268901.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 处理装备卡发动时的选择操作，包括选择装备对象和设置操作信息
function c32268901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32268901.filter(chkc) end
	-- 检查是否存在可以成为装备对象的炎属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c32268901.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择一个符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c32268901.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备效果，涉及一张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给选定的目标怪兽
function c32268901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将当前装备卡装备到目标怪兽上
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
