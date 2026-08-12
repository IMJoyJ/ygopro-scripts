--サディスティック・ポーション
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。这张卡的控制者用卡的效果给与对方玩家伤害的场合，直到那个回合的结束阶段时装备怪兽的攻击力上升1000。
function c30155789.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c30155789.cost)
	e1:SetTarget(c30155789.target)
	e1:SetOperation(c30155789.operation)
	c:RegisterEffect(e1)
end
-- 将此卡留在场上，防止其因效果而送去墓地。
function c30155789.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于后续连锁判断。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后留在场上。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 当此卡被无效时，取消其送去墓地的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c30155789.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁无效效果注册给玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，取消此卡送去墓地。
function c30155789.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 判断是否满足发动条件。
function c30155789.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return e:IsCostChecked()
		-- 检索场上存在的1只表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将装备卡装备给怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 将此卡装备给选中的怪兽。
function c30155789.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取此卡的装备对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 当此卡的控制者用卡的效果给与对方玩家伤害的场合，直到那个回合的结束阶段时装备怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_DAMAGE)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c30155789.damcon)
		e1:SetOperation(c30155789.damop)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 限制此卡只能装备给特定怪兽。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c30155789.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 限制此卡只能装备给自身或控制者为发动者本人的怪兽。
function c30155789.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
-- 判断是否为效果伤害且伤害来源为对方。
function c30155789.damcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep~=tp and rp==tp
end
-- 使装备怪兽的攻击力上升1000。
function c30155789.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 使装备怪兽的攻击力上升1000，直到回合结束阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
