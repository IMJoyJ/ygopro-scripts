--A・∀・HH
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ●对方：装备怪兽变成里侧守备表示。
function c92650018.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c92650018.cost)
	e1:SetTarget(c92650018.target)
	e1:SetOperation(c92650018.operation)
	c:RegisterEffect(e1)
	-- ②：可以把装备怪兽的控制者对应的以下效果发动。●自己：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92650018,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,92650018)
	e2:SetCondition(c92650018.discon)
	e2:SetTarget(c92650018.distg)
	e2:SetOperation(c92650018.disop)
	c:RegisterEffect(e2)
	-- ②：可以把装备怪兽的控制者对应的以下效果发动。●对方：装备怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92650018,1))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,92650018)
	e3:SetCondition(c92650018.poscon)
	e3:SetTarget(c92650018.postg)
	e3:SetOperation(c92650018.posop)
	c:RegisterEffect(e3)
end
-- 陷阱卡发动时的Cost函数，用于处理陷阱卡发动被无效时送去墓地的规则处理（防止非永续陷阱卡在发动无效时滞留场上，并注册相关重置效果）。
function c92650018.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID。
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
	e2:SetOperation(c92650018.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 在全局注册一个在连锁被无效时触发的连续效果，用于处理该卡发动被无效时送去墓地的规则。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁发动无效时的效果处理函数，若本卡的发动被无效，则将其送去墓地。
function c92650018.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤自己场上的「惊乐」怪兽或对方场上的表侧表示怪兽。
function c92650018.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 陷阱卡发动时的对象选择与效果分类注册函数。
function c92650018.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c92650018.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在可以作为装备对象的合法怪兽（自己场上的「惊乐」怪兽或对方场上的表侧表示怪兽）。
		and Duel.IsExistingTarget(c92650018.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择1只合法的怪兽作为装备对象。
	local g=Duel.SelectTarget(tp,c92650018.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置当前连锁的操作信息为：将自身作为装备卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 陷阱卡发动时的效果处理函数，将自身装备给目标怪兽并添加装备限制。
function c92650018.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的第一个对象（即要装备的怪兽）。
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
			e1:SetValue(c92650018.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制函数，规定此卡只能装备给自身装备的目标，且必须是自己场上的「惊乐」怪兽或对方场上的怪兽。
function c92650018.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 效果②（自己控制）的发动条件：装备怪兽的控制者是自己。
function c92650018.discon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 效果②（自己控制）的对象选择与效果分类注册函数。
function c92650018.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 指向对象筛选：必须是对方场上表侧表示且未被无效的效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在可以被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效效果的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只效果怪兽作为无效对象。
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为：使目标怪兽的效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果②（自己控制）的效果处理函数，使目标怪兽的效果直到回合结束时无效。
function c92650018.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取要无效的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使与目标怪兽相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 效果②（对方控制）的发动条件：装备怪兽的控制者是对方。
function c92650018.poscon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(1-tp)
end
-- 效果②（对方控制）的发动准备与效果分类注册函数，检查装备怪兽是否可以变成里侧表示。
function c92650018.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsCanTurnSet() end
	-- 设置当前连锁的操作信息为：改变装备怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ec,1,0,0)
end
-- 效果②（对方控制）的效果处理函数，将装备怪兽变成里侧守备表示。
function c92650018.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 将装备怪兽改变为里侧守备表示。
		Duel.ChangePosition(ec,POS_FACEDOWN_DEFENSE)
	end
end
