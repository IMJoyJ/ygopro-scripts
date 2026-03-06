--甲虫装機の手甲
-- 效果：
-- 发动后这张卡变成守备力上升1000的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。装备怪兽不会被对方的卡的效果破坏。
function c259314.initial_effect(c)
	-- 发动后这张卡变成守备力上升1000的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。装备怪兽不会被对方的卡的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c259314.cost)
	e1:SetTarget(c259314.target)
	e1:SetOperation(c259314.operation)
	c:RegisterEffect(e1)
end
-- 设置此卡在发动后会留在场上，且在连锁被无效时会取消送入墓地
function c259314.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡发动后会留在场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 设置当此卡的连锁被无效时，若此卡仍存在于连锁中则取消送入墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c259314.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，用于判断是否为当前连锁并取消送入墓地
function c259314.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤场上名字带有「甲虫装机」的怪兽
function c259314.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 设置效果发动时的条件，检查是否满足目标选择条件
function c259314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c259314.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在名字带有「甲虫装机」的怪兽
		and Duel.IsExistingTarget(c259314.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上名字带有「甲虫装机」的怪兽作为装备对象
	Duel.SelectTarget(tp,c259314.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时的操作信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备卡的效果处理，包括装备怪兽、增加守备力、设置装备限制和不可破坏效果
function c259314.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备卡使装备怪兽守备力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
		-- 设置装备卡只能装备给名字带有「甲虫装机」的怪兽
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c259314.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 设置装备怪兽不会被对方的卡的效果破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 设置装备怪兽不会被对方的卡的效果破坏
		e3:SetValue(aux.indoval)
		c:RegisterEffect(e3,true)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制函数，判断目标怪兽是否可以被此装备卡装备
function c259314.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x56)
end
