--反目の従者
-- 效果：
-- 装备怪兽的控制权转移时，给与装备怪兽的控制者装备怪兽的原本攻击力数值的伤害。
function c21702241.initial_effect(c)
	-- 装备怪兽（此卡作为装备魔法发动并装备给怪兽）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c21702241.target)
	e1:SetOperation(c21702241.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽（装备对象限定为怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 的控制权转移时，给与装备怪兽的控制者装备怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21702241,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CONTROL_CHANGED)
	e3:SetCondition(c21702241.damcon)
	e3:SetTarget(c21702241.damtg)
	e3:SetOperation(c21702241.damop)
	c:RegisterEffect(e3)
end
-- 发动时选择自己或对方场上1只表侧表示怪兽作为装备对象，并设置将这张卡装备给该怪兽的操作信息。
function c21702241.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查双方场上是否存在1只表侧表示怪兽作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽作为这张卡的装备对象，并将其登记为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的处理信息：这张卡将作为装备卡装备给对象（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和所选对象都与效果关联且对象仍为表侧表示，则将这张卡装备给该对象。
function c21702241.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡（装备目标）。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 发动条件判定：这张卡的装备怪兽在控制权变更的卡集合中，即装备怪兽的控制权发生了转移。
function c21702241.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	return tg and eg:IsContains(tg)
end
-- 伤害效果发动前的目标判定：确认此卡不在连锁处理中，取得装备怪兽，并设置对其控制者造成原本攻击力数值伤害的操作信息。
function c21702241.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	-- 设置操作信息：对装备怪兽当前控制者造成其原本攻击力数值的伤害（CATEGORY_DAMAGE）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,ec:GetControler(),ec:GetBaseAttack())
end
-- 伤害效果处理：给装备怪兽当前控制者造成其原本攻击力数值的伤害。
function c21702241.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 实际执行伤害：对装备怪兽当前控制者造成其原本攻击力数值的伤害，伤害原因为效果。
	Duel.Damage(ec:GetControler(),ec:GetBaseAttack(),REASON_EFFECT)
end
