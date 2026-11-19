--A・∀・MM
-- 效果：
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：装备怪兽的控制者对应的以下效果适用。
-- ●自己：装备怪兽的攻击力上升500。装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
-- ●对方：装备怪兽的攻击力下降给怪兽装备的自己的「游乐设施」陷阱卡数量×500。
function c29867611.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置发动时点限制，限制这张卡只能在伤害步骤的伤害计算前或非伤害步骤发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c29867611.cost)
	e1:SetTarget(c29867611.target)
	e1:SetOperation(c29867611.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的控制者对应的以下效果适用。●自己：装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	e2:SetCondition(c29867611.con)
	c:RegisterEffect(e2)
	-- 装备怪兽被战斗·效果破坏的场合，可以作为代替把这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c29867611.desrepcon)
	e3:SetTarget(c29867611.desreptg)
	e3:SetOperation(c29867611.desrepop)
	c:RegisterEffect(e3)
	-- ●对方：装备怪兽的攻击力下降给怪兽装备的自己的「游乐设施」陷阱卡数量×500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(c29867611.atkval)
	e4:SetCondition(c29867611.atkcon)
	c:RegisterEffect(e4)
end
-- 发动Cost函数：为这张陷阱卡注册在连锁期间留在场上的机制效果，并在当前连锁被无效时取消其送去墓地的预定状态。
function c29867611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c29867611.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 为玩家注册用于监听连锁是否被无效的辅助诱发即时效果。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效处理函数：当发生连锁无效事件且连锁ID匹配时，若这张卡仍与该连锁相关，则取消其自动送去墓地的状态。
function c29867611.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的那个连锁(ev)的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义对象过滤函数，检查场上怪兽是否为表侧表示，且为自己的「惊乐」怪兽或对方控制的怪兽。
function c29867611.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 发动对象检查函数：确认已执行Cost检查，且场上存在至少1只符合条件的自己「惊乐」怪兽或对方表侧表示怪兽。
function c29867611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29867611.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 在检查能否发动时，确认双方怪兽区存在至少1只满足条件且可成为效果对象的怪兽。
		and Duel.IsExistingTarget(c29867611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家发送选择要装备怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只满足条件的怪兽作为当前连锁的发动对象。
	local g=Duel.SelectTarget(tp,c29867611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 向引擎登记将这张卡自身装备给目标怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理函数：若对象怪兽仍表侧在场且这张卡未确定离场，则将这张卡当作装备卡装备给对象怪兽并设置装备对象限制；否则取消留在场上状态使这张卡送去墓地。
function c29867611.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡自身以表侧表示当作装备卡装备给对象怪兽。
			Duel.Equip(tp,c,tc)
			-- 这张卡当作装备卡使用给那只怪兽装备。
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
-- 定义装备对象限制函数：允许这张卡继续装备于当前装备怪兽，或者符合自己「惊乐」怪兽及对方怪兽的合法转移目标。
function c29867611.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 己方装备效果适用条件函数：判断当前装备怪兽的控制者是否为这张卡的控制者自己。
function c29867611.con(e)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
-- 代替破坏条件函数：确认存在装备怪兽且装备怪兽的控制者为这张卡的控制者自己。
function c29867611.desrepcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 代替破坏检查函数：确认装备怪兽因战斗或效果将被破坏且非代替破坏状态，同时这张卡自身未被确认破坏。
function c29867611.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsReason(REASON_BATTLE+REASON_EFFECT) and not ec:IsReason(REASON_REPLACE)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 弹出效果提示，让玩家选择是否适用这张卡的代替破坏效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏处理函数：将这张装备卡作为效果代替破坏送去墓地。
function c29867611.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果且代替破坏的原因将这张卡自身送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 对方装备效果适用条件函数：判断当前装备怪兽的控制者是否为这张卡控制者的对方。
function c29867611.atkcon(e)
	return e:GetHandler():GetEquipTarget():IsControler(1-e:GetHandlerPlayer())
end
-- 定义「游乐设施」陷阱卡过滤函数，检查卡片是否为表侧表示、属于「游乐设施」(0x15c)字段、为陷阱卡且正处于装备怪兽的状态。
function c29867611.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:GetEquipTarget()
end
-- 攻击力下降数值计算函数：统计自己魔法与陷阱区满足条件的表侧装备中「游乐设施」陷阱卡数量，并按每张下降500攻击力返回负值。
function c29867611.atkval(e,c)
	-- 统计自己魔法与陷阱区当前正在装备怪兽的表侧「游乐设施」陷阱卡数量。
	local ct=Duel.GetMatchingGroupCount(c29867611.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
	return ct*-500
end
