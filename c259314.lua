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
	-- 设置效果发动条件：只能在进行伤害计算前的伤害步骤发动（由aux.dscon判断）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c259314.cost)
	e1:SetTarget(c259314.target)
	e1:SetOperation(c259314.operation)
	c:RegisterEffect(e1)
end
-- 无实际代价，但设置保护：为此卡附加EFFECT_REMAIN_FIELD（留在场上）的誓约效果，并注册EVENT_CHAIN_DISABLED的监视效果；若此卡发动的连锁被无效，则将其从墓地取回。
function c259314.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 取得当前连锁的ID（CHAININFO_CHAIN_ID），用于后续在连锁被无效时判断是否为本卡的发动连锁。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成守备力上升1000的装备卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 给自己场上1只名字带有「甲虫装机」的怪兽装备。装备怪兽不会被对方的卡的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c259314.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将该监视效果注册到场上，使连锁被无效时触发tgop。
	Duel.RegisterEffect(e2,tp)
end
-- tgop操作：当此卡发动所在的连锁被无效时，若此卡仍与该连锁关联，则将其从墓地取回（不送去墓地）。
function c259314.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，用于与保存的本卡发动连锁ID比对。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 装备对象筛选：表侧表示且卡名含有「甲虫装机」字段的怪兽。
function c259314.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 目标选择处理：在发动时检查并选择自己场上1只表侧表示的「甲虫装机」怪兽作为装备对象。
function c259314.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c259314.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断自己场上是否存在至少1只符合条件的「甲虫装机」怪兽。
		and Duel.IsExistingTarget(c259314.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择自己场上1只符合条件的「甲虫装机」怪兽，并将其登记为本连锁的对象。
	Duel.SelectTarget(tp,c259314.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，声明此卡将作为装备卡进行装备，供相关连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍合法，则将其装备给对象怪兽，并给该怪兽附加守备力上升1000和不被对方效果破坏的效果；否则此卡送去墓地。
function c259314.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得效果处理时的对象怪兽（此前选择的目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 守备力上升1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		c:RegisterEffect(e1)
		-- 给自己场上1只名字带有「甲虫装机」的怪兽装备
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c259314.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 装备怪兽不会被对方的卡的效果破坏。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 设置‘不会被对方的卡的效果破坏’的判定值为aux.indoval，即仅当破坏效果的发动者是对方玩家时适用。
		e3:SetValue(aux.indoval)
		c:RegisterEffect(e3,true)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制条件：此卡只能装备给当前的装备目标，或装备给自己场上名字带有「甲虫装机」的怪兽；防止装备对象不合法。
function c259314.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x56)
end
