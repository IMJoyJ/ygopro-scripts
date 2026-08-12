--甲虫装機の宝珠
-- 效果：
-- 发动后这张卡变成攻击力·守备力上升500的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。自己场上的名字带有「甲虫装机」的怪兽1只成为卡的效果的对象时，可以把变成装备卡的这张卡送去墓地，那个效果无效。
function c38643567.initial_effect(c)
	-- 效果发动后这张卡变成攻击力·守备力上升500的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c38643567.cost)
	e1:SetTarget(c38643567.target)
	e1:SetOperation(c38643567.operation)
	c:RegisterEffect(e1)
end
-- 设置此卡在发动时不会被无效，同时注册一个连锁被无效时的处理效果
function c38643567.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后不会被送入墓地
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个用于检测连锁是否被无效的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c38643567.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，取消此卡送入墓地的操作
function c38643567.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选场上正面表示且为「甲虫装机」卡组的怪兽
function c38643567.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 判断是否满足发动条件，即场上是否存在符合条件的怪兽
function c38643567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38643567.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断是否满足发动条件，即场上是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c38643567.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c38643567.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理装备卡的装备效果
function c38643567.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 使装备卡的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 使装备卡的守备力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 设置装备卡只能装备给特定怪兽
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c38643567.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		-- 设置一个可在连锁时发动的效果，用于无效对方效果
		local e4=Effect.CreateEffect(c)
		e4:SetDescription(aux.Stringid(38643567,0))  --"效果无效"
		e4:SetType(EFFECT_TYPE_QUICK_O)
		e4:SetCategory(CATEGORY_DISABLE)
		e4:SetCode(EVENT_CHAINING)
		e4:SetRange(LOCATION_SZONE)
		e4:SetCondition(c38643567.ngcon)
		e4:SetCost(c38643567.ngcost)
		e4:SetTarget(c38643567.ngtg)
		e4:SetOperation(c38643567.ngop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
	else
		c:CancelToGrave(false)
	end
end
-- 设置装备卡的装备限制条件
function c38643567.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x56)
end
-- 判断连锁是否可以被无效，且目标怪兽为场上甲虫装机怪兽
function c38643567.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取连锁的触发位置和目标卡组
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	local tc=tg:GetFirst()
	if tg:GetCount()~=1 or not tc:IsLocation(LOCATION_MZONE) or not tc:IsSetCard(0x56) then return false end
	-- 判断连锁是否可以被无效，且目标不在牌组
	return Duel.IsChainDisablable(ev) and loc~=LOCATION_DECK
end
-- 设置无效效果时的费用，将此卡送入墓地
function c38643567.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置无效效果时的操作信息
function c38643567.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果时的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使连锁效果无效
function c38643567.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效
	Duel.NegateEffect(ev)
end
