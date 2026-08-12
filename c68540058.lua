--メタル化・魔法反射装甲
-- 效果：
-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升300的装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽的攻击力只在向怪兽攻击的伤害计算时上升那只攻击对象怪兽的攻击力一半数值。
function c68540058.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升300的装备卡使用给那只怪兽装备。②：用这张卡的效果把这张卡装备的怪兽的攻击力只在向怪兽攻击的伤害计算时上升那只攻击对象怪兽的攻击力一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果在伤害步骤中伤害计算前（或非伤害步骤）可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c68540058.cost)
	e1:SetTarget(c68540058.target)
	e1:SetOperation(c68540058.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价：在连锁处理结束前将这张卡留在场上，并注册连锁被无效时送去墓地的效果
function c68540058.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升300的装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c68540058.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在连锁被无效时将此卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的处理：若此卡的发动被无效，则取消“留在场上”的状态，使其正常送去墓地
function c68540058.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：场上表侧表示的怪兽
function c68540058.filter(c)
	return c:IsFaceup()
end
-- 定义效果的发动目标：选择场上1只表侧表示怪兽
function c68540058.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68540058.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
		and Duel.IsExistingTarget(c68540058.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c68540058.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备卡片
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义效果处理：将这张卡装备给目标怪兽，并适用攻击力·守备力上升以及进行攻击时攻击力再上升的效果
function c68540058.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作攻击力·守备力上升300的装备卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		-- 给那只怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		-- ②：用这张卡的效果把这张卡装备的怪兽的攻击力只在向怪兽攻击的伤害计算时上升那只攻击对象怪兽的攻击力一半数值。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_EQUIP)
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetProperty(0,EFFECT_FLAG2_REPEAT_UPDATE)
		e4:SetCondition(c68540058.atkcon)
		e4:SetValue(c68540058.atkval)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
	else
		c:CancelToGrave(false)
	end
end
-- 定义攻击力上升效果的适用条件：仅在装备怪兽向对方怪兽进行攻击的伤害计算时
function c68540058.atkcon(e)
	-- 判定当前阶段是否为伤害计算时
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 判定攻击怪兽是否为装备怪兽，且存在攻击对象（即向怪兽攻击）
		and Duel.GetAttacker()==e:GetHandler():GetEquipTarget() and Duel.GetAttackTarget()
end
-- 定义攻击力上升数值的计算函数
function c68540058.atkval(e,c)
	-- 计算并返回攻击对象怪兽攻击力一半的数值（向上取整）
	return math.ceil(Duel.GetAttackTarget():GetAttack()/2)
end
