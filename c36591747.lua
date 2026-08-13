--A・∀・TT
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：装备怪兽的表示形式变更，自己墓地1张「游乐设施」陷阱卡由对方选出。那张卡在自己场上盖放。
-- ●对方：装备怪兽直到结束阶段除外。
function c36591747.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
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
	-- 这个卡名的②的效果1回合只能使用1次。●自己：装备怪兽的表示形式变更，自己墓地1张「游乐设施」陷阱卡由对方选出。那张卡在自己场上盖放。
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
	-- 这个卡名的②的效果1回合只能使用1次。●对方：装备怪兽直到结束阶段除外。
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
-- ①发动的cost处理：无实际代价，但为这张卡附加本次连锁内留在场上的效果（EFFECT_REMAIN_FIELD），并注册连锁被无效时的辅助效果；若这张卡的发动被无效，则通过tgop取消其被送去墓地的处理，使其继续留在场上。
function c36591747.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁ID，用于标记本次①效果的发动，以便后续连锁被无效时能对应判断。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 对应①效果的“这张卡当作装备卡使用给那只怪兽装备。”——设置EFFECT_REMAIN_FIELD使发动中的此卡在本连锁处理期间不会因各种原因离开场上，确保装备处理能完成。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 这段代码整体实现①效果的发动、对象选取、装备以及发动被无效时的保持处理，对应原文：“①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c36591747.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监听“连锁被无效”事件的全场型辅助效果注册给当前玩家tp，在该连锁被无效时执行tgop以保护此卡不去墓地。
	Duel.RegisterEffect(e2,tp)
end
-- 辅助效果处理函数：取得被无效连锁的ID，若与本次①发动的连锁ID相同，且此卡仍与该连锁相关，则调用CancelToGrave取消此卡因发动被无效而进入墓地的处理。
function c36591747.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从被无效的连锁中取得该连锁的ID，用于和保存的本次发动连锁ID比对。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义①可选择/装备的对象条件：表侧表示怪兽，并且是己方场上「惊乐」怪兽或对方场上的表侧表示怪兽。
function c36591747.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- ①效果的发动目标判定与目标选择：确认可以支付cost、存在合法对象后，从双方场上选择1只符合条件的表侧表示怪兽作为对象。
function c36591747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36591747.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 判断双方主要怪兽区是否有至少1只符合条件的表侧表示怪兽（己方「惊乐」怪兽或对方表侧表示怪兽），作为①能否发动的条件。
		and Duel.IsExistingTarget(c36591747.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 给发动玩家显示选择提示，内容是请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让发动玩家从自己或对方场上选择1只符合条件的表侧表示怪兽，并作为当前连锁的对象登记。
	local g=Duel.SelectTarget(tp,c36591747.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 将本次连锁的操作信息设置为装备卡装备，对象为这张卡自身，数量1，供后续规则判定使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ①效果处理：若对象怪兽仍与效果相关且表侧表示，且此卡仍可处理，则把此卡装备给对象，并追加装备限制效果；若对象不再适合装备且此卡仍可处理，则此卡不去墓地（留在场上）。
function c36591747.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 由发动玩家把这张卡当作装备卡装备给选定的对象怪兽。
			Duel.Equip(tp,c,tc)
			-- 对应①效果的“这张卡当作装备卡使用给那只怪兽装备。”——为装备状态下的此卡设定装备限制：只能装备给己方「惊乐」怪兽或对方表侧表示怪兽（并始终允许装备给原本对象）。
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
-- 装备限制判定函数：该装备卡只允许装备给原本装备对象，或者我方场上的「惊乐」怪兽、对方场上的表侧表示怪兽，以保证装备关系合法。
function c36591747.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- ②自己分支的发动条件：此卡处于装备状态，且装备怪兽的控制者是发动玩家自己。
function c36591747.stcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 墓地检索过滤：选择自己墓地中「游乐设施」字段的陷阱卡，并且该卡能够被盖放到场上。
function c36591747.stfilter(c)
	return c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②自己分支的目标判定：装备怪兽可变更表示形式，且自己墓地有符合条件的「游乐设施」陷阱卡时可发动；发动时预告将变更表示形式并盖放墓地陷阱卡。
function c36591747.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsCanChangePosition()
		-- 确认自己墓地存在至少1张符合条件的「游乐设施」陷阱卡。
		and Duel.IsExistingMatchingCard(c36591747.stfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 将本次连锁的操作信息标记为变更表示形式，对象确定为装备怪兽，数量1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ec,1,0,0)
	-- 将本次连锁的操作信息标记为涉及墓地，预计1张卡从自己墓地离开，用于相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- ②自己分支处理：若条件满足，先变更装备怪兽的表示形式；变更成功后让对手从自己墓地的「游乐设施」陷阱卡中选1张，再由自己把该卡盖放在自己场上。
function c36591747.stop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 从自己墓地取得全部符合条件的「游乐设施」陷阱卡，作为待对方选择的候选组。
	local g=Duel.GetMatchingGroup(c36591747.stfilter,tp,LOCATION_GRAVE,0,nil)
	if ec and c:IsRelateToEffect(e)
		-- 变更装备怪兽表示形式，并确认变更成功（返回值非0）后才继续处理墓地陷阱卡。
		and Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0
		and g:GetCount()>0 then
		-- 向对方玩家显示选择提示，要求其选出一张要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(1-tp,1,1,nil)
		if sg:GetCount()>0 then
			-- 由发动玩家将对方选出的陷阱卡盖放在自己场上（里侧表示）。
			Duel.SSet(tp,sg)
		end
	end
end
-- ②对方分支的发动条件：此卡处于装备状态，且装备怪兽的控制者是对手。
function c36591747.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(1-tp)
end
-- ②对方分支的目标判定：装备怪兽存在且能够被除外时才能发动；发动时预告将除外该装备怪兽。
function c36591747.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsAbleToRemove(tp) end
	-- 将本次连锁的操作信息标记为除外，对象为装备怪兽，数量1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,ec,1,0,0)
end
-- ②对方分支处理：若装备怪兽仍存在且此卡效果相关，则将该怪兽暂时除外（REASON_TEMPORARY），并注册结束阶段返回效果。
function c36591747.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 判断装备怪兽仍可处理、此卡仍关联效果，并且装备怪兽成功被暂时除外；只有成功除外时才需要设置返回效果。
	if ec and c:IsRelateToEffect(e) and Duel.Remove(ec,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 对应“●对方：装备怪兽直到结束阶段除外。”——这部分实现“直到结束阶段”后的归还：在结束阶段把暂时除外的怪兽返回场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(ec)
		e1:SetCountLimit(1)
		e1:SetOperation(c36591747.retop)
		-- 将“结束阶段归还怪兽”的延迟效果注册到环境中，由发动玩家控制，在结束阶段时自动执行归还。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段的归还处理函数：把之前被暂时除外的装备怪兽返回场上。
function c36591747.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 把之前被暂时除外的装备怪兽按离场前表示形式返回场上（需要场上存在可用区域）。
	Duel.ReturnToField(e:GetLabelObject())
end
