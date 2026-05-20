--燃える闘志
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上表侧表示存在的1只怪兽装备。攻击力比原本攻击力高的怪兽在对方场上存在的场合，装备怪兽的攻击力在伤害步骤内变成原本攻击力的2倍。
function c68054593.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上表侧表示存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置发动条件：在伤害步骤中，只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c68054593.cost)
	e1:SetTarget(c68054593.target)
	e1:SetOperation(c68054593.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的Cost：在连锁处理结束前将自身留在场上，并注册连锁被无效时防止送去墓地的效果
function c68054593.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成装备卡，给自己场上表侧表示存在的1只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c68054593.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将用于处理连锁无效时的效果注册给发动玩家
	Duel.RegisterEffect(e2,tp)
end
-- 定义连锁无效时的处理：若该卡仍与该连锁相关，则取消送去墓地的状态，使其留在场上
function c68054593.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发事件的连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：选择场上表侧表示的怪兽
function c68054593.filter(c)
	return c:IsFaceup()
end
-- 定义效果发动的目标选择：选择自己场上1只表侧表示的怪兽作为装备对象，并设置操作信息
function c68054593.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c68054593.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只可以作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(c68054593.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果的对象
	Duel.SelectTarget(tp,c68054593.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将自身作为装备卡装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义效果处理：将自身装备给目标怪兽，并注册攻击力翻倍的效果和装备限制
function c68054593.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取在发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 攻击力比原本攻击力高的怪兽在对方场上存在的场合，装备怪兽的攻击力在伤害步骤内变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetCondition(c68054593.atkcon)
		e1:SetValue(c68054593.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 给自己场上表侧表示存在的1只怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c68054593.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 定义装备限制：只能装备给装备怪兽或自己场上的怪兽
function c68054593.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
-- 过滤条件：对方场上表侧表示且当前攻击力比原本攻击力高的怪兽
function c68054593.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 定义攻击力翻倍效果的适用条件：当前处于伤害步骤（或伤害计算时），且对方场上存在攻击力比原本攻击力高的怪兽
function c68054593.atkcon(e)
	-- 检查当前阶段是否为伤害步骤或伤害计算阶段
	return (Duel.GetCurrentPhase()==PHASE_DAMAGE or Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL)
		-- 检查对方场上是否存在至少1只攻击力比原本攻击力高的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c68054593.atkfilter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end
-- 定义攻击力数值：返回装备怪兽原本攻击力的2倍
function c68054593.atkval(e,c)
	return c:GetBaseAttack()*2
end
