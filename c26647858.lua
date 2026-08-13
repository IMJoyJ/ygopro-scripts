--ヒーロー・ヘイロー
-- 效果：
-- 发动后这张卡变成装备卡，攻击力1500以下的1只战士族怪兽装备。对方的攻击力1900以上的怪兽不能攻击装备怪兽。
function c26647858.initial_effect(c)
	-- 发动后这张卡变成装备卡，攻击力1500以下的1只战士族怪兽装备。对方的攻击力1900以上的怪兽不能攻击装备怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c26647858.cost)
	e1:SetTarget(c26647858.target)
	e1:SetOperation(c26647858.operation)
	c:RegisterEffect(e1)
end
-- 发动时无实际代价，但设置此卡在连锁处理结束后留在场上的誓约效果，并注册连锁被无效时将卡送去墓地的辅助效果，以确保发动被无效时处理正确。
function c26647858.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，供后续判断是否为同一连锁。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 攻击力1500以下的1只战士族怪兽装备。对方的攻击力1900以上的怪兽不能攻击装备怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c26647858.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 把连锁被无效时的辅助效果注册给当前玩家，用于该连锁被无效时触发补救处理。
	Duel.RegisterEffect(e2,tp)
end
-- 当有连锁被无效时，若其连锁ID与此效果记录的一致，且此卡仍与该连锁关联，则将其强制送去墓地，以取代因留在场上效果而滞留在场上的情况。
function c26647858.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，用于与发动时记录的连锁ID比对。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 判定怪兽是否为表侧表示、攻击力1500以下且战士族，作为可装备对象。
function c26647858.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500) and c:IsRace(RACE_WARRIOR)
end
-- 处理取对象判定：若检查对象，则要求该对象在怪兽区且满足筛选条件；若为发动确认，则要求已满足代价检查且场上存在1只符合条件的装备对象。
function c26647858.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c26647858.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 确认双方怪兽区存在至少1只满足筛选条件（表侧攻击力1500以下战士族）的怪兽，可作为装备对象。
		and Duel.IsExistingTarget(c26647858.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示选择提示“请选择要装备的卡”，用于引导选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只符合条件的表侧战士族怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c26647858.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本效果将进行装备处理，装备对象为此卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若此卡仍在魔陷区且与效果关联，则取出装备对象，将此卡装备给对象；随后赋予其“不能成为攻击对象”的装备效果，并设置装备限制；若对象不在或非法，则将此卡送去墓地。
function c26647858.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取出发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 对方的攻击力1900以上的怪兽不能攻击装备怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e1:SetValue(c26647858.atval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力1500以下的1只战士族怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c26647858.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制判定：此卡只能装备给当前装备对象，或攻击力1500以下且战士族的怪兽，防止错误装备。
function c26647858.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsAttackBelow(1500) and c:IsRace(RACE_WARRIOR)
end
-- 作为“不能成为攻击对象”的判定：攻击怪兽攻击力在1900以上且不对该效果免疫时，不能攻击装备怪兽；否则可以攻击。
function c26647858.atval(e,c)
	return c:IsAttackAbove(1900) and not c:IsImmuneToEffect(e)
end
