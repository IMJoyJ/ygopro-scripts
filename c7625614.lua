--レアゴールド・アーマー
-- 效果：
-- 只要控制装备这张卡的怪兽，对方不能攻击装备怪兽以外的怪兽。
function c7625614.initial_effect(c)
	-- （装备魔法卡的发动）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c7625614.target)
	e1:SetOperation(c7625614.operation)
	c:RegisterEffect(e1)
	-- 只要控制装备这张卡的怪兽，对方不能攻击装备怪兽以外的怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c7625614.atkcon)
	e2:SetValue(c7625614.atktg)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 作为装备魔法卡发动时的效果处理，确认场上是否存在表侧表示怪兽并进行取对象选择
function c7625614.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 在发动阶段，检查场上是否存在至少1只表侧表示的怪兽作为合法的装备对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表明该效果包含装备操作，操作对象为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 作为装备魔法卡发动时的效果处理，将这张卡装备给选择的怪兽
function c7625614.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 攻击限制效果的适用条件：装备怪兽存在，且装备怪兽的控制权属于装备卡的控制者
function c7625614.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetControler()==e:GetHandlerPlayer()
end
-- 攻击限制效果的对象过滤：除装备了这张卡的怪兽以外的怪兽
function c7625614.atktg(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
