--反目の従者
-- 效果：
-- 装备怪兽的控制权转移时，给与装备怪兽的控制者装备怪兽的原本攻击力数值的伤害。
function c21702241.initial_effect(c)
	-- 装备怪兽的控制权转移时，给与装备怪兽的控制者装备怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c21702241.target)
	e1:SetOperation(c21702241.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的控制权转移时，给与装备怪兽的控制者装备怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 装备怪兽的控制权转移时，给与装备怪兽的控制者装备怪兽的原本攻击力数值的伤害。
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
-- 选择一个对方场上的表侧表示怪兽作为装备对象。
function c21702241.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只对方场上的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时将要装备的卡作为操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 将装备卡装备给选择的怪兽。
function c21702241.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断控制权变更的怪兽是否为当前装备卡的装备对象。
function c21702241.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	return tg and eg:IsContains(tg)
end
-- 设置伤害效果的目标和伤害值。
function c21702241.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	local ec=e:GetHandler():GetEquipTarget()
	if not ec then return false end
	-- 设置将要造成伤害的玩家和伤害数值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,ec:GetControler(),ec:GetBaseAttack())
end
-- 对装备怪兽的控制者造成伤害。
function c21702241.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 对装备怪兽的控制者造成其原本攻击力数值的伤害。
	Duel.Damage(ec:GetControler(),ec:GetBaseAttack(),REASON_EFFECT)
end
