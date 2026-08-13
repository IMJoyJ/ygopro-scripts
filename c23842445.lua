--ニトロユニット
-- 效果：
-- 对方场上的怪兽才能装备。装备怪兽被战斗破坏送去墓地时，给与对方基本分装备怪兽攻击力数值的伤害。
function c23842445.initial_effect(c)
	-- 对方场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c23842445.target)
	e1:SetOperation(c23842445.operation)
	c:RegisterEffect(e1)
	-- 对方场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c23842445.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽被战斗破坏送去墓地时，给与对方基本分装备怪兽攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23842445,0))  --"LP伤害"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c23842445.damcon)
	e3:SetTarget(c23842445.damtg)
	e3:SetOperation(c23842445.damop)
	c:RegisterEffect(e3)
end
-- 装备限制判定：候选装备怪兽必须是这张装备卡控制者的对方所控制的怪兽，即只能装备在对方场上的怪兽。
function c23842445.eqlimit(e,c)
	return c:IsControler(1-e:GetHandlerPlayer())
end
-- 装备魔法发动前的取对象处理：检查对方场上是否存在表侧表示怪兽，并选择1只作为装备对象，同时设置后续装备的操作信息。
function c23842445.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判定效果能否发动：检查对方场上是否存在至少1只表侧表示怪兽，可作为这张装备卡的装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，告知玩家需要选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从对方场上选择1只表侧表示怪兽，并将该卡登记为这张装备魔法卡的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本连锁进行装备卡装备的处理，目标为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡的效果处理：若这张卡和目标怪兽仍有效且目标怪兽为表侧表示，则将这张卡装备给目标怪兽。
function c23842445.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的目标怪兽，作为将要装备的对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备到目标怪兽的装备区域。
		Duel.Equip(tp,c,tc)
	end
end
-- 伤害触发条件：这张装备卡因失去装备对象而离场（被送入墓地），且原装备怪兽是被战斗破坏后送去墓地。
function c23842445.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_BATTLE)
end
-- 设定伤害效果的发动条件通过后，记载伤害对象和伤害数值：原装备怪兽的攻击力即为伤害值，对象为对方玩家。
function c23842445.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetPreviousEquipTarget():GetAttack()
	-- 将本次效果的伤害对象设定为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值记录为连锁参数，数值为原装备怪兽的攻击力。
	Duel.SetTargetParam(dam)
	-- 设置连锁操作信息：将对对方玩家造成dam点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理：根据连锁记录，对目标玩家造成伤害。
function c23842445.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出之前记录的目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式对目标玩家造成伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
