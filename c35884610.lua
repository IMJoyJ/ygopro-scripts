--U.A.パワードギプス
-- 效果：
-- 「超级运动员」怪兽才能装备。
-- ①：装备怪兽的攻击力·守备力上升1000，装备怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
-- ②：装备怪兽的攻击破坏怪兽的场合才能发动。这次战斗阶段中，装备怪兽只再1次可以攻击。
-- ③：自己准备阶段发动。装备怪兽除外。
-- ④：装备怪兽回到手卡让这张卡被送去墓地的场合才能发动。这张卡回到手卡。
function c35884610.initial_effect(c)
	-- 「超级运动员」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c35884610.target)
	e1:SetOperation(c35884610.operation)
	c:RegisterEffect(e1)
	-- 「超级运动员」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c35884610.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力·守备力上升1000
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 装备怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetCondition(c35884610.damcon)
	-- 将战斗伤害设为2倍，且变更对象为对方玩家，实现给与对方双倍战斗伤害。
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
	-- 装备怪兽的攻击破坏怪兽的场合才能发动。这次战斗阶段中，装备怪兽只再1次可以攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(35884610,0))  --"连续攻击"
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_BATTLED)
	e6:SetCondition(c35884610.atcon)
	e6:SetOperation(c35884610.atop)
	c:RegisterEffect(e6)
	-- 自己准备阶段发动。装备怪兽除外。
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetCondition(c35884610.rmcon)
	e7:SetTarget(c35884610.rmtg)
	e7:SetOperation(c35884610.rmop)
	c:RegisterEffect(e7)
	-- 装备怪兽回到手卡让这张卡被送去墓地的场合才能发动。这张卡回到手卡。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(35884610,1))  --"返回手卡"
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCondition(c35884610.thcon)
	e8:SetTarget(c35884610.thtg)
	e8:SetOperation(c35884610.thop)
	c:RegisterEffect(e8)
end
-- 装备对象限制：仅允许装备字段为「超级运动员」的怪兽。
function c35884610.eqlimit(e,c)
	return c:IsSetCard(0xb2)
end
-- 筛选场上表侧表示且属于「超级运动员」字段的怪兽。
function c35884610.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2)
end
-- 处理装备魔法发动：选择场上1只表侧表示「超级运动员」怪兽作为装备对象，并登记装备处理。
function c35884610.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c35884610.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只可装备的表侧表示「超级运动员」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c35884610.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要装备的卡”的提示，供玩家选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 在双方怪兽区选择1张符合条件的「超级运动员」怪兽作为装备对象（取对象）。
	Duel.SelectTarget(tp,c35884610.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁的处理信息为“将这张卡装备给对象”。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若装备卡及对象仍与效果关联且对象表侧表示，则执行装备。
function c35884610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给目标「超级运动员」怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 战斗伤害翻倍效果的触发条件：装备怪兽在场且与对方怪兽进行了战斗（存在战斗对象）。
function c35884610.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
-- 追加攻击效果的触发条件：装备怪兽通过战斗破坏了对方怪兽，且装备怪兽当前可以发动攻击（满足连锁攻击限制）。
function c35884610.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsChainAttackable()
end
-- 给装备怪兽附加本次战斗阶段中可再攻击1次的效果。
function c35884610.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetHandler():GetEquipTarget()
	-- 这次战斗阶段中，装备怪兽只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e1)
end
-- 自己准备阶段除外效果的发动条件：当前回合玩家是这张卡的控制者。
function c35884610.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为卡片控制者，即是否为自己准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- 除外效果的目标处理：无选择操作，登记将装备怪兽除外的操作信息。
function c35884610.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本次处理将装备怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler():GetEquipTarget(),1,0,0)
end
-- 效果处理时，若装备怪兽仍在场上，则将其表侧表示除外。
function c35884610.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec then
		-- 将装备怪兽从场上除外。
		Duel.Remove(ec,POS_FACEUP,REASON_EFFECT)
	end
end
-- 返回手卡效果的触发条件：这张卡因装备怪兽回到手卡而失去装备对象被送去墓地，且原装备怪兽现在在手卡。
function c35884610.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_HAND)
end
-- 返回手卡效果的目标检查：确认此卡能被加入手卡，并登记操作信息。
function c35884610.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 登记操作信息：本次处理将把这张卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理返回手卡：若这张卡仍与当前效果关联，则将其送至持有者手卡。
function c35884610.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
