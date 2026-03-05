--愚鈍の斧
-- 效果：
-- ①：装备怪兽的攻击力上升1000，效果无效化。
-- ②：自己准备阶段发动。给与装备怪兽的控制者500伤害。
function c19578592.initial_effect(c)
	-- ①：装备怪兽的攻击力上升1000，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19578592.target)
	e1:SetOperation(c19578592.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 装备怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	-- 装备对象限制。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ②：自己准备阶段发动。给与装备怪兽的控制者500伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(19578592,0))  --"500伤害"
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c19578592.damcon)
	e5:SetTarget(c19578592.damtg)
	e5:SetOperation(c19578592.damop)
	c:RegisterEffect(e5)
end
-- 判断是否满足选择装备目标的条件。
function c19578592.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择装备目标的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择装备目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的怪兽作为装备目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时要装备的卡片信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡的发动处理。
function c19578592.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 准备阶段伤害效果的发动条件判断。
function c19578592.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家。
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段伤害效果的目标设定。
function c19578592.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 设定伤害效果的目标玩家。
	Duel.SetTargetPlayer(p)
	-- 设定伤害效果的伤害值为500。
	Duel.SetTargetParam(500)
	-- 设置伤害效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
-- 准备阶段伤害效果的处理。
function c19578592.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetEquipTarget():GetControler()
	-- 获取连锁中设定的伤害值。
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
