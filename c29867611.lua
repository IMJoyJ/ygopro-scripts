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
	-- 设置①效果的发动条件，使其在伤害步骤内且尚未进行伤害计算时也能发动（限制在伤害计算前）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c29867611.cost)
	e1:SetTarget(c29867611.target)
	e1:SetOperation(c29867611.operation)
	c:RegisterEffect(e1)
	-- ●自己：装备怪兽的攻击力上升500。
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
	e3:SetValue(c29867611.desrepval)
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
-- ①效果的发动代价处理函数：无实际支付代价，但给这张卡附加本连锁内留在场上的誓约效果，并注册连锁被无效时取消卡片“确定送去墓地”的监视效果，以保证这张卡在发动后能正常装备。
function c29867611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于标记本次发动，便于后续连锁被无效时准确处理这张卡。
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
	-- 将用于监视本次连锁是否被无效的持续效果注册到发动者场上。
	Duel.RegisterEffect(e2,tp)
end
-- 当本次发动的连锁被无效时，若这张卡仍与该连锁关联，则取消其“确定送去墓地”的状态，使这张卡不会因发动被无效而送入墓地。
function c29867611.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID，用于判断当前无效事件是否针对本次发动。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义装备对象的选择过滤条件：选择自己场上表侧表示的「惊乐」怪兽或对方场上的表侧表示怪兽。
function c29867611.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- ①效果的发动目标判定：若指定对象，则验证其在怪兽区且满足过滤条件；发动时确认没有其他限制且存在合法对象。
function c29867611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29867611.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在至少1只可作为装备对象的怪兽（自己表侧「惊乐」怪兽或对方表侧怪兽）。
		and Duel.IsExistingTarget(c29867611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从符合条件的怪兽中选择1只作为装备对象，并将其登记为本次效果的对象。
	local g=Duel.SelectTarget(tp,c29867611.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁处理信息，声明本效果涉及将这张卡装备给对象，供相关卡牌或效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若对象仍合法且这张卡仍在场上，则将其装备给对象，并给这张卡设置装备限制效果；若对象不合法但卡仍在场上，则取消其“确定送去墓地”状态。
function c29867611.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡作为装备卡装备给目标怪兽。
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
-- 定义装备限制条件：允许装备给当前装备目标、自己场上的「惊乐」怪兽或对方场上的怪兽。
function c29867611.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 定义攻击力+500效果的适用条件：装备怪兽的控制者是自己（这张卡的控制者）。
function c29867611.con(e)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
-- 定义代替破坏效果的适用条件：装备怪兽的控制者是自己（这张卡的控制者）。
function c29867611.desrepcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 判定是否适用代替破坏：当装备怪兽将要被战斗或效果破坏，且不是被代替破坏，且这张卡尚未确定被破坏时，返回true，允许询问是否代替。
function c29867611.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsReason(REASON_BATTLE+REASON_EFFECT) and not ec:IsReason(REASON_REPLACE)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 询问装备怪兽的控制者是否选择将这张卡送去墓地来代替装备怪兽被破坏。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏的判定函数：确认被破坏的怪兽是否为这张卡的装备对象（相当于代替破坏的发动条件判定）。
function c29867611.desrepval(e,c)
	return c29867611.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果处理：将这张装备卡送去墓地，从而代替装备怪兽被破坏。
function c29867611.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以“效果+代替破坏”的理由送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- 定义攻击力下降效果的适用条件：装备怪兽的控制者是这张卡控制者的对方。
function c29867611.atkcon(e)
	return e:GetHandler():GetEquipTarget():IsControler(1-e:GetHandlerPlayer())
end
-- 筛选自己场上表侧表示且处于装备状态的「游乐设施」陷阱卡。
function c29867611.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:GetEquipTarget()
end
-- 计算攻击力下降数值：统计满足条件的「游乐设施」陷阱卡数量，乘以-500作为攻击力增减值。
function c29867611.atkval(e,c)
	-- 统计自己魔陷区中满足条件的「游乐设施」陷阱卡的数量。
	local ct=Duel.GetMatchingGroupCount(c29867611.atkfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)
	return ct*-500
end
