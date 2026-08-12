--A・∀・MM
-- 效果：
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：装备怪兽的控制者对应的以下效果适用。
-- ●自己：装备怪兽的攻击力上升500。装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
-- ●对方：装备怪兽的攻击力下降给怪兽装备的自己的「游乐设施」陷阱卡数量×500。
function c29867611.initial_effect(c)
	-- 创建装备效果，设置为自由连锁发动，具有取对象和伤害步骤发动属性，限制在伤害步骤前发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 效果发动时机限制在伤害步骤前
	e1:SetCondition(aux.dscon)
	e1:SetCost(c29867611.cost)
	e1:SetTarget(c29867611.target)
	e1:SetOperation(c29867611.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的控制者为自己的场合，装备怪兽攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetCondition(c29867611.con)
	c:RegisterEffect(e2)
	-- 装备怪兽的控制者为对方的场合，装备怪兽攻击力下降给怪兽装备的自己的「游乐设施」陷阱卡数量×500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c29867611.desrepcon)
	e3:SetTarget(c29867611.desreptg)
	e3:SetValue(c29867611.desrepval)
	e3:SetOperation(c29867611.desrepop)
	c:RegisterEffect(e3)
	-- 装备怪兽的控制者为对方的场合，装备怪兽攻击力下降给怪兽装备的自己的「游乐设施」陷阱卡数量×500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c29867611.atkval)
	e4:SetCondition(c29867611.atkcon)
	c:RegisterEffect(e4)
end
-- 设置发动时的费用，使此卡在发动后不会被无效
function c29867611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在发动后不会被移除场外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁被无效时的处理效果，用于防止此卡被无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c29867611.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，若为当前连锁则取消送入墓地
function c29867611.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取指定连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选目标怪兽，必须为表侧表示且为「惊乐」怪兽或对方场上的怪兽
function c29867611.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 设置目标选择条件，必须为场上的表侧表示怪兽
function c29867611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29867611.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c29867611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的目标怪兽
	local g=Duel.SelectTarget(tp,c29867611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息，表示将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将此卡装备给目标怪兽
function c29867611.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将此卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 设置装备限制效果，防止被其他装备卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c29867611.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制函数，判断是否可以装备给指定怪兽
function c29867611.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 装备怪兽的控制者为自己的场合，此效果适用
function c29867611.con(e)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
-- 装备怪兽的控制者为自己的场合，此效果适用
function c29867611.desrepcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 判断是否可以发动代替破坏效果
function c29867611.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsReason(REASON_BATTLE+REASON_EFFECT) and not ec:IsReason(REASON_REPLACE)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏效果的值
function c29867611.desrepval(e,c)
	return c29867611.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果，将此卡送去墓地
function c29867611.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 装备怪兽的控制者为对方的场合，此效果适用
function c29867611.atkcon(e)
	return e:GetHandler():GetEquipTarget():IsControler(1-e:GetHandlerPlayer())
end
-- 筛选装备的「游乐设施」陷阱卡
function c29867611.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:GetEquipTarget()
end
-- 计算装备的「游乐设施」陷阱卡数量并计算攻击力下降值
function c29867611.atkval(e,c)
	-- 计算装备的「游乐设施」陷阱卡数量
	local ct=Duel.GetMatchingGroupCount(c29867611.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
	return ct*-500
end
