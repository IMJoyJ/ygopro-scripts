--魔界の足枷
-- 效果：
-- ①：装备怪兽不能攻击，攻击力·守备力变成100。
-- ②：自己准备阶段发动。给与装备怪兽的控制者500伤害。
function c83584898.initial_effect(c)
	-- ①：装备怪兽不能攻击，攻击力·守备力变成100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c83584898.target)
	e1:SetOperation(c83584898.operation)
	c:RegisterEffect(e1)
	-- 攻击力·守备力变成100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(100)
	c:RegisterEffect(e2)
	-- 攻击力·守备力变成100
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_DEFENSE)
	e3:SetValue(100)
	c:RegisterEffect(e3)
	-- 装备怪兽不能攻击
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
	-- 装备怪兽
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ②：自己准备阶段发动。给与装备怪兽的控制者500伤害。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(83584898,0))  --"500伤害"
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(c83584898.damcon)
	e6:SetTarget(c83584898.damtg)
	e6:SetOperation(c83584898.damop)
	c:RegisterEffect(e6)
end
-- 装备魔法卡发动时的对象选择与操作信息设置
function c83584898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以装备的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备自身的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理（将自身装备给目标怪兽）
function c83584898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查当前是否为自己的回合（自己准备阶段的判定条件）
function c83584898.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为效果的发动者
	return tp==Duel.GetTurnPlayer()
end
-- 伤害效果的发动准备，确定受伤害的玩家并设置伤害数值
function c83584898.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 设置受到伤害的目标玩家为装备怪兽的控制者
	Duel.SetTargetPlayer(p)
	-- 设置伤害数值为500
	Duel.SetTargetParam(500)
	-- 设置连锁信息，表示该效果包含给与玩家500伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
-- 伤害效果的实际处理，给与目标玩家伤害
function c83584898.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 获取当前连锁中设定的伤害数值
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 因效果给与装备怪兽的控制者伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
