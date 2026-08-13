--月鏡の盾
-- 效果：
-- ①：这张卡的装备怪兽和对方怪兽进行战斗的伤害计算时发动。装备怪兽的攻击力·守备力只在伤害计算时变成进行战斗的对方怪兽的攻击力和守备力之内较高方的数值＋100。
-- ②：表侧表示的这张卡从场上送去墓地的场合，支付500基本分发动。这张卡回到卡组最上面或者最下面。
function c19508728.initial_effect(c)
	-- 对应①前半句：这张卡的装备怪兽和对方怪兽进行战斗的伤害计算时发动。此处为装备魔法卡的发动处理：选择场上1只表侧表示怪兽作为装备对象，并将此卡装备给该怪兽，使其成为“这张卡的装备怪兽”。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c19508728.target)
	e1:SetOperation(c19508728.activate)
	c:RegisterEffect(e1)
	-- 对应“这张卡的装备怪兽”（装备魔法卡基本限制）：设置此卡只能装备给怪兽的装备限制。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 对应①：这张卡的装备怪兽和对方怪兽进行战斗的伤害计算时发动。装备怪兽的攻击力·守备力只在伤害计算时变成进行战斗的对方怪兽的攻击力和守备力之内较高方的数值＋100。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c19508728.atkcon)
	e3:SetOperation(c19508728.atkop)
	c:RegisterEffect(e3)
	-- 对应②：表侧表示的这张卡从场上送去墓地的场合，支付500基本分发动。这张卡回到卡组最上面或者最下面。
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
-- 装备魔法卡发动时的目标选择：检查是否存在表侧表示怪兽可作为装备对象；若连锁处理中指定了对象，则需要该对象为场上表侧表示怪兽；满足条件时提示玩家选择要装备的怪兽，并将选择的怪兽设为效果对象，同时设置本效果将进行装备操作的信息。
function c19508728.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件检查：确认场上存在至少1只表侧表示怪兽，可以作为此装备卡的装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要装备的卡”的提示信息，用于选择怪兽的界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽，将其作为此装备卡的装备对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明当前效果将把装备卡（此卡自身）装备给对象，类别为装备，数量为1，用于连锁响应检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的处理：若此卡仍与效果关联，且选择的对象仍与效果关联且为表侧表示，则将此卡装备给该对象。
function c19508728.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给对象怪兽，完成装备魔法卡的装备处理。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 伤害计算时效果的发动条件：判断此卡的装备怪兽是否存在战斗对象，且战斗对象为对方的表侧表示怪兽。
function c19508728.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	return ec and tc and tc:IsFaceup() and tc:IsControler(1-tp)
end
-- 伤害计算时效果的发动处理：若装备怪兽和对方战斗怪兽均为表侧表示，取对方怪兽攻击力与守备力的较高值，为装备怪兽附加攻击力、守备力变成该数值+100的效果，该效果在伤害计算阶段结束时重置。
function c19508728.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if ec and tc and ec:IsFaceup() and tc:IsFaceup() then
		local val=math.max(tc:GetAttack(),tc:GetDefense())
		-- 对应①中“装备怪兽的攻击力·守备力只在伤害计算时变成进行战斗的对方怪兽的攻击力和守备力之内较高方的数值＋100”（此处为攻击力部分：将攻击力设定为较高值+100）。
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
-- ②的发动条件：此卡从场上表侧表示状态下被送去墓地（即之前位置为场上且表侧表示）。
function c19508728.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- ②的发动代价：检查能否支付500基本分，若能则支付500基本分。
function c19508728.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分作为发动②的代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- ②的发动目标：本效果无需选择对象；设置要将此卡送回卡组的操作信息。
function c19508728.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将要把此卡（自身）送回持有者卡组，类别为回卡组，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②的效果处理：若此卡仍能与效果关联（未被除外等），让玩家选择放回卡组最上面或最下面，然后按选择送回持有者卡组。
function c19508728.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 让玩家选择将这张卡放回卡组最上面还是最下面（选项为“卡组最上面/卡组最下面”）。
		local opt=Duel.SelectOption(tp,aux.Stringid(19508728,0),aux.Stringid(19508728,1))  --"卡组最上面/卡组最下面"
		-- 将这张卡以效果原因送去玩家（持有者）卡组的指定位置（最上面opt=0/最下面opt=1）。
		Duel.SendtoDeck(e:GetHandler(),nil,opt,REASON_EFFECT)
	end
end
