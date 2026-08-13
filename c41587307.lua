--折れ竹光
-- 效果：
-- ①：装备怪兽的攻击力上升0。
function c41587307.initial_effect(c)
	-- ①：装备怪兽的攻击力上升0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c41587307.target)
	e1:SetOperation(c41587307.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 发动时的目标选择处理：检查对象是否为场上表侧表示怪兽，若无合法对象且不在选择阶段则判定不可发动；提示“请选择要装备的卡”，选择1只表侧表示怪兽作为装备对象，并登记装备类操作信息。
function c41587307.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 非效果处理时，检查场上是否存在至少1只表侧表示怪兽可作为装备对象，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家弹出选择提示（HINTMSG_EQUIP），内容为“请选择要装备的卡”，实际是选择要装备给的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方场上选择1只表侧表示怪兽作为这张装备卡的装备对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为“装备”（CATEGORY_EQUIP），声明本连锁处理时将把这张装备卡装备给对象，供其他卡效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：取出装备对象，确认装备卡与对象仍与本次连锁相关且对象仍为表侧表示后，执行装备处理。
function c41587307.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给选定的对象怪兽，完成装备魔法卡的装备动作。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
