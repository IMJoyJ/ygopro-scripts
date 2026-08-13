--サラマンドラ
-- 效果：
-- 炎属性怪兽才能装备。
-- ①：装备怪兽的攻击力上升700。
function c32268901.initial_effect(c)
	-- 对应效果原文：“炎属性怪兽才能装备。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c32268901.target)
	e1:SetOperation(c32268901.operation)
	c:RegisterEffect(e1)
	-- 对应效果原文：“①：装备怪兽的攻击力上升700。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 对应效果原文：“炎属性怪兽才能装备。”
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c32268901.eqlimit)
	c:RegisterEffect(e4)
end
-- 该函数为装备限制判定：只有炎属性怪兽才能被这张卡装备，返回true表示允许装备。
function c32268901.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 该函数为可装备对象筛选条件：怪兽必须是表侧表示且为炎属性。
function c32268901.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 发动时的目标选择处理：确认存在符合条件的表侧炎属性怪兽后，提示玩家选择1只作为装备对象，并设置装备操作信息。
function c32268901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32268901.filter(chkc) end
	-- 发动合法性检查：当chk==0时，检测场上是否存在至少1只符合条件的表侧炎属性怪兽，以决定是否可发动。
	if chk==0 then return Duel.IsExistingTarget(c32268901.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送“请选择要装备的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只符合条件的表侧炎属性怪兽，作为这张卡的装备对象（取对象）。
	Duel.SelectTarget(tp,c32268901.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次连锁的操作信息设置为装备类别，处理目标为本卡，数量为1，用于相关效果（如星尘龙等）的发动检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时执行装备：若这张卡与选择的对象仍关联且对象仍为表侧表示，则把这张卡装备给该怪兽。
function c32268901.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的那只装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给选择的对象，装备后其攻击力上升700。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
