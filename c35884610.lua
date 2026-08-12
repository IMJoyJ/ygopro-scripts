--U.A.パワードギプス
-- 效果：
-- 「超级运动员」怪兽才能装备。
-- ①：装备怪兽的攻击力·守备力上升1000，装备怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
-- ②：装备怪兽的攻击破坏怪兽的场合才能发动。这次战斗阶段中，装备怪兽只再1次可以攻击。
-- ③：自己准备阶段发动。装备怪兽除外。
-- ④：装备怪兽回到手卡让这张卡被送去墓地的场合才能发动。这张卡回到手卡。
function c35884610.initial_effect(c)
	-- ①：装备怪兽的攻击力·守备力上升1000，装备怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
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
	-- 装备怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetCondition(c35884610.damcon)
	-- 设置战斗伤害为对方受到的伤害翻倍
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
-- 限制只能装备到「超级运动员」怪兽
function c35884610.eqlimit(e,c)
	return c:IsSetCard(0xb2)
end
-- 筛选场上正面表示的「超级运动员」怪兽
function c35884610.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb2)
end
-- 选择场上正面表示的「超级运动员」怪兽作为装备对象
function c35884610.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c35884610.filter(chkc) end
	-- 判断是否存在符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c35884610.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,c35884610.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c35884610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备怪兽是否参与了战斗
function c35884610.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
-- 判断装备怪兽是否破坏了对方怪兽且可以进行连锁攻击
function c35884610.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsChainAttackable()
end
-- 为装备怪兽增加1次攻击机会
function c35884610.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetHandler():GetEquipTarget()
	-- 为装备怪兽增加1次攻击机会
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e1)
end
-- 判断是否为自己的准备阶段
function c35884610.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果拥有者
	return Duel.GetTurnPlayer()==tp
end
-- 设置除外效果的处理信息
function c35884610.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置除外效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler():GetEquipTarget(),1,0,0)
end
-- 执行除外操作
function c35884610.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec then
		-- 将装备怪兽除外
		Duel.Remove(ec,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断装备怪兽是否因失去装备对象而被送去墓地且其前装备怪兽在手卡
function c35884610.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_HAND)
end
-- 设置返回手卡效果的处理信息
function c35884610.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置返回手卡效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行返回手卡操作
function c35884610.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备卡送回手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
