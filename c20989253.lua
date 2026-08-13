--アメイズメント・ファミリーフェイス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以有自己的「游乐设施」陷阱卡装备的对方场上1只怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：得到装备怪兽的控制权。
-- ③：装备怪兽只要在自己的怪兽区域存在，攻击力上升500，不能把效果发动，也当作「惊乐」怪兽使用。
function c20989253.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以有自己的「游乐设施」陷阱卡装备的对方场上1只怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,20989253+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c20989253.cost)
	e1:SetTarget(c20989253.target)
	e1:SetOperation(c20989253.operation)
	c:RegisterEffect(e1)
	-- ②：得到装备怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetValue(c20989253.cval)
	c:RegisterEffect(e2)
	-- ③：装备怪兽只要在自己的怪兽区域存在，攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	e3:SetCondition(c20989253.con)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(20989253,0))  --"「惊乐家族脸」效果适用中"
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e5:SetValue(0x15b)
	c:RegisterEffect(e5)
end
-- 发动时的费用处理：无实际cost，但设置本卡在连锁处理期间留在场上，并注册连锁被无效时取消送去墓地的辅助效果，以支持作为装备卡的效果。
function c20989253.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一ID，用于标记本次发动。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- ①：这张卡当作装备卡使用给那只怪兽装备（发动后作为装备卡留在场上，不会被规则送去墓地）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以有自己的「游乐设施」陷阱卡装备的对方场上1只怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备（发动时监视连锁被无效，选择对象并进行装备）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c20989253.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监视连锁被无效的辅助效果注册到当前玩家场上，用于处理本次发动被无效的场合。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：若被无效的连锁正是本次发动，且本卡仍与连锁相关，则取消本卡送去墓地的状态，使其留在场上。
function c20989253.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的唯一ID，用于与本次发动标记比较。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选条件：表侧表示且为「游乐设施」字段的陷阱卡，且控制者为tp（自己）。
function c20989253.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsControler(tp)
end
-- 筛选对象：对方场上的表侧怪兽，其装备区存在自己控制的「游乐设施」陷阱卡，且控制权可以被改变。
function c20989253.filter(c,tp)
	return c:IsFaceup() and c:GetEquipGroup():IsExists(c20989253.cfilter,1,nil,tp) and c:IsControlerCanBeChanged()
end
-- 发动的目标选择：判断连锁对象是否合法；存在合法对象时才可发动。
function c20989253.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c20989253.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查对方场上是否存在1只满足条件的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c20989253.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 向玩家显示选择提示，提示选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 由玩家从对方怪兽区域选择1只满足条件的怪兽，并将其指定为本效果的对象。
	local g=Duel.SelectTarget(tp,c20989253.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：本次连锁将进行装备操作，装备卡为本卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次连锁将改变对象怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理时：若对象仍合法且本卡在场上，则将本卡装备给对象，并附加装备限制；若对象不合法，本卡不去墓地，仍留在场上。
function c20989253.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的对象怪兽（选择的那1只）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡作为装备卡，装备给对象怪兽。
			Duel.Equip(tp,c,tc)
			-- ①：以有自己的「游乐设施」陷阱卡装备的对方场上1只怪兽为对象（装备对象限制：只能装备给当前对象或其他满足条件的对方怪兽）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c20989253.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制条件：允许装备给当前装备目标，或对方控制的且装备有「游乐设施」陷阱卡的怪兽。
function c20989253.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(1-tp) and c:GetEquipGroup():IsExists(c20989253.cfilter,1,nil,tp)
end
-- 控制权变更值：返回装备卡的控制者，即装备怪兽的控制权转移给这张装备卡的控制者。
function c20989253.cval(e,c)
	return e:GetHandlerPlayer()
end
-- 攻击力上升等效果适用条件：装备怪兽当前的控制者与装备卡的控制者相同（即在自己场上）。
function c20989253.con(e)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
