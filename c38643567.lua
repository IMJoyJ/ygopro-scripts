--甲虫装機の宝珠
-- 效果：
-- 发动后这张卡变成攻击力·守备力上升500的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。自己场上的名字带有「甲虫装机」的怪兽1只成为卡的效果的对象时，可以把变成装备卡的这张卡送去墓地，那个效果无效。
function c38643567.initial_effect(c)
	-- 发动后这张卡变成攻击力·守备力上升500的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设定发动条件：只能在伤害步骤且伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c38643567.cost)
	e1:SetTarget(c38643567.target)
	e1:SetOperation(c38643567.operation)
	c:RegisterEffect(e1)
end
-- 发动前的处理：无实际cost；为这张卡附加直到连锁结束留在场上的誓约效果，并注册一个本连锁被无效时取消将其送去墓地的辅助效果，以防发动被无效时错误送墓。
function c38643567.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 取得当前连锁的ChainID，用于后续识别本连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成攻击力·守备力上升500的装备卡，给自己场上1只名字带有「甲虫装机」的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c38643567.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监听连锁被无效的辅助效果注册到场上，由发动方控制。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：若宝珠仍与该连锁关联，则取消其因发动被无效而被送去墓地的处理。
function c38643567.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被无效连锁的ChainID，与之前记录的ChainID比对，只处理本连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：表侧表示且卡名带有「甲虫装机」的怪兽。
function c38643567.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x56)
end
-- 发动时的目标处理：确认代价已检查且自己场上存在符合条件的甲虫装机怪兽；若为选择对象阶段则检查所选卡是否合法。
function c38643567.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c38643567.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只表侧表示的「甲虫装机」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c38643567.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择要装备的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「甲虫装机」怪兽作为这张卡的装备对象。
	Duel.SelectTarget(tp,c38643567.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：把这张卡自身作为装备卡处理，并标记为装备分类，供相关卡片/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动处理：若这张卡仍在魔陷区且与发动连锁关联，则将对象怪兽装备，并赋予其攻击力·守备力各上升500、装备限制，以及作为装备卡时的无效效果；若不满足条件则取消送墓。
function c38643567.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 攻击力·守备力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力·守备力上升500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给自己场上1只名字带有「甲虫装机」的怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c38643567.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		-- 自己场上的名字带有「甲虫装机」的怪兽1只成为卡的效果的对象时，可以把变成装备卡的这张卡送去墓地，那个效果无效。
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
-- 装备限制条件：只允许装备给当前装备对象，或自己场上名字带有「甲虫装机」的怪兽，防止非法装备。
function c38643567.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x56)
end
-- 无效效果的发动条件：被连锁的效果必须是取对象效果，且其对象是己方场上唯一1只「甲虫装机」怪兽；该连锁可被无效，且发动位置不在卡组。
function c38643567.ngcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 取得当前连锁效果的发动位置以及其对象卡组。
	local loc,tg=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TARGET_CARDS)
	local tc=tg:GetFirst()
	if tg:GetCount()~=1 or not tc:IsLocation(LOCATION_MZONE) or not tc:IsSetCard(0x56) then return false end
	-- 判定该连锁效果能否被无效，且不是从卡组发动的效果。
	return Duel.IsChainDisablable(ev) and loc~=LOCATION_DECK
end
-- 无效效果的代价：检查这张装备卡是否可作为代价送去墓地，并执行送墓。
function c38643567.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张装备卡送去墓地作为代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 无效效果的目标处理：无取对象，直接确认可以发动并设置操作信息。
function c38643567.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将正在连锁的那张卡（效果来源）标记为将被无效，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效效果的处理：使对应的连锁效果无效。
function c38643567.ngop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际执行无效，将指定连锁的效果无效化。
	Duel.NegateEffect(ev)
end
