--月鏡の盾
-- 效果：
-- ①：这张卡的装备怪兽和对方怪兽进行战斗的伤害计算时发动。装备怪兽的攻击力·守备力只在伤害计算时变成进行战斗的对方怪兽的攻击力和守备力之内较高方的数值＋100。
-- ②：表侧表示的这张卡从场上送去墓地的场合，支付500基本分发动。这张卡回到卡组最上面或者最下面。
function c19508728.initial_effect(c)
	-- ①：这张卡的装备怪兽和对方怪兽进行战斗的伤害计算时发动。装备怪兽的攻击力·守备力只在伤害计算时变成进行战斗的对方怪兽的攻击力和守备力之内较高方的数值＋100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19508728.target)
	e1:SetOperation(c19508728.activate)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡从场上送去墓地的场合，支付500基本分发动。这张卡回到卡组最上面或者最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：这张卡的装备怪兽和对方怪兽进行战斗的伤害计算时发动。装备怪兽的攻击力·守备力只在伤害计算时变成进行战斗的对方怪兽的攻击力和守备力之内较高方的数值＋100。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c19508728.atkcon)
	e3:SetOperation(c19508728.atkop)
	c:RegisterEffect(e3)
	-- ②：表侧表示的这张卡从场上送去墓地的场合，支付500基本分发动。这张卡回到卡组最上面或者最下面。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c19508728.tdcon)
	e4:SetCost(c19508728.tdcost)
	e4:SetTarget(c19508728.tdtg)
	e4:SetOperation(c19508728.tdop)
	c:RegisterEffect(e4)
end
-- 选择装备怪兽
function c19508728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在可选择的装备怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡效果处理
function c19508728.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害计算时的条件判断
function c19508728.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	return ec and tc and tc:IsFaceup() and tc:IsControler(1-tp)
end
-- 伤害计算时改变攻击力和守备力
function c19508728.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if ec and tc and ec:IsFaceup() and tc:IsFaceup() then
		local val=math.max(tc:GetAttack(),tc:GetDefense())
		-- 设置装备怪兽的攻击力为对方怪兽攻击力和守备力较高值加100
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(val+100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		ec:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		ec:RegisterEffect(e2)
	end
end
-- 送去墓地时的条件判断
function c19508728.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 支付500基本分的费用处理
function c19508728.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 设置送去卡组的效果操作信息
function c19508728.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果操作信息为送去卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 卡组回到卡组最上面或最下面的效果处理
function c19508728.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 选择将卡送回卡组最上面或最下面
		local opt=Duel.SelectOption(tp,aux.Stringid(19508728,0),aux.Stringid(19508728,1))  --"卡组最上面/卡组最下面"
		-- 将卡送回卡组指定位置
		Duel.SendtoDeck(e:GetHandler(),nil,opt,REASON_EFFECT)
	end
end
