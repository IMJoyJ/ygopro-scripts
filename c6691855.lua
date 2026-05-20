--鎖付き尖盾
-- 效果：
-- 发动后这张卡变成攻击力上升500的装备卡，给场上1只怪兽装备。装备怪兽以守备表示进行战斗的场合，装备怪兽的守备力只在伤害计算时上升那个攻击力数值。
function c6691855.initial_effect(c)
	-- 发动后这张卡变成攻击力上升500的装备卡，给场上1只怪兽装备。装备怪兽以守备表示进行战斗的场合，装备怪兽的守备力只在伤害计算时上升那个攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果发动条件：在伤害步骤中，仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c6691855.cost)
	e1:SetTarget(c6691855.target)
	e1:SetOperation(c6691855.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost函数，用于处理陷阱卡发动后留在场上以及连锁被无效时送去墓地的规则处理
function c6691855.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成攻击力上升500的装备卡，给场上1只怪兽装备。装备怪兽以守备表示进行战斗的场合，装备怪兽的守备力只在伤害计算时上升那个攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c6691855.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册一个全局效果，用于在连锁被无效时将此卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的操作函数，取消此卡留在场上的状态并送去墓地
function c6691855.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：场上表侧表示的怪兽
function c6691855.filter(c)
	return c:IsFaceup()
end
-- 效果发动的靶向选择函数，确认发动合法性并选择装备对象
function c6691855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c6691855.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
		and Duel.IsExistingTarget(c6691855.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送选择装备对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c6691855.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行装备操作并适用攻击力与守备力上升的效果
function c6691855.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取在发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 变成攻击力上升500的装备卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备怪兽以守备表示进行战斗的场合，装备怪兽的守备力只在伤害计算时上升那个攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetProperty(0,EFFECT_FLAG2_REPEAT_UPDATE)
		e2:SetCondition(c6691855.defcon)
		e2:SetValue(c6691855.defval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给场上1只怪兽装备
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 守备力上升效果的适用条件判定函数
function c6691855.defcon(e)
	-- 判定当前阶段是否为伤害计算时，若不是则不适用守备力上升效果
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE_CAL then return false end
	local eq=e:GetHandler():GetEquipTarget()
	-- 判定装备怪兽是否为攻击怪兽或被攻击怪兽，且处于守备表示
	return (eq==Duel.GetAttacker() or eq==Duel.GetAttackTarget()) and eq:IsDefensePos()
end
-- 守备力上升数值的计算函数，返回装备怪兽当前的攻击力数值
function c6691855.defval(e,c)
	return c:GetAttack()
end
