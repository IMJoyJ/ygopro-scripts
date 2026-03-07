--A・∀・TT
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：装备怪兽的表示形式变更，自己墓地1张「游乐设施」陷阱卡由对方选出。那张卡在自己场上盖放。
-- ●对方：装备怪兽直到结束阶段除外。
function c36591747.initial_effect(c)
	-- 效果原文：①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c36591747.cost)
	e1:SetTarget(c36591747.target)
	e1:SetOperation(c36591747.operation)
	c:RegisterEffect(e1)
	-- 效果原文：②：可以把装备怪兽的控制者对应的以下效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,36591747)
	e2:SetCondition(c36591747.stcon)
	e2:SetTarget(c36591747.sttg)
	e2:SetOperation(c36591747.stop)
	c:RegisterEffect(e2)
	-- 效果原文：●对方：装备怪兽直到结束阶段除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_CHAIN_END+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,36591747)
	e3:SetCondition(c36591747.rmcon)
	e3:SetTarget(c36591747.rmtg)
	e3:SetOperation(c36591747.rmop)
	c:RegisterEffect(e3)
end
-- 规则层面：设置发动时的费用，防止连锁被无效时将此卡返回手牌
function c36591747.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 规则层面：获取当前正在处理的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 规则层面：设置此卡在发动后不会因效果而离场
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 规则层面：注册连锁被无效时的处理效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c36591747.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 规则层面：将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 规则层面：连锁被无效时的处理函数，若连锁ID匹配则取消此卡进入墓地
function c36591747.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 规则层面：过滤函数，筛选满足条件的怪兽
function c36591747.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 规则层面：设置发动时的目标选择条件
function c36591747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36591747.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 规则层面：检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c36591747.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 规则层面：提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 规则层面：选择目标怪兽
	local g=Duel.SelectTarget(tp,c36591747.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 规则层面：设置操作信息，表示此效果会装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 规则层面：设置装备卡的处理函数
function c36591747.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 规则层面：将此卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 效果原文：这张卡当作装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c36591747.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 规则层面：设置装备限制条件，防止被其他装备卡装备
function c36591747.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 规则层面：设置②效果发动的条件，即装备怪兽为己方控制
function c36591747.stcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 规则层面：过滤函数，筛选满足条件的「游乐设施」陷阱卡
function c36591747.stfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 规则层面：设置②效果发动时的目标选择条件
function c36591747.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsCanChangePosition()
		-- 规则层面：检查是否存在满足条件的墓地「游乐设施」陷阱卡
		and Duel.IsExistingMatchingCard(c36591747.stfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面：设置操作信息，表示此效果会改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ec,1,0,0)
	-- 规则层面：设置操作信息，表示此效果会从墓地取出卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 规则层面：设置②效果的处理函数
function c36591747.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 规则层面：获取满足条件的墓地「游乐设施」陷阱卡组
	local g=Duel.GetMatchingGroup(c36591747.stfilter,tp,LOCATION_GRAVE,0,nil)
	if ec and c:IsRelateToEffect(e)
		-- 规则层面：改变目标怪兽的表示形式
		and Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and g:GetCount()>0 then
		-- 规则层面：提示对方选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(1-tp,1,1,nil)
		if sg:GetCount()>0 then
			-- 规则层面：将选择的卡在己方场上盖放
			Duel.SSet(tp,sg)
		end
	end
end
-- 规则层面：设置②效果发动的条件，即装备怪兽为对方控制
function c36591747.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(1-tp)
end
-- 规则层面：设置②效果发动时的目标选择条件
function c36591747.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsAbleToRemove(tp) end
	-- 规则层面：设置操作信息，表示此效果会除外卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,ec,1,0,0)
end
-- 规则层面：设置②效果的处理函数
function c36591747.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 规则层面：判断是否可以将目标怪兽除外
	if ec and c:IsRelateToEffect(e) and Duel.Remove(ec,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 效果原文：●自己：装备怪兽的表示形式变更，自己墓地1张「游乐设施」陷阱卡由对方选出。那张卡在自己场上盖放。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(ec)
		e1:SetCountLimit(1)
		e1:SetOperation(c36591747.retop)
		-- 规则层面：将效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 规则层面：设置返回场上的处理函数
function c36591747.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：将目标怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
