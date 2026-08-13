--サディスティック・ポーション
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。这张卡的控制者用卡的效果给与对方玩家伤害的场合，直到那个回合的结束阶段时装备怪兽的攻击力上升1000。
function c30155789.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。这张卡的控制者用卡的效果给与对方玩家伤害的场合，直到那个回合的结束阶段时装备怪兽的攻击力上升1000。
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
-- 作为发动代价，为这张卡附加在当前连锁处理期间留在场上的誓约效果，并注册一个在连锁被无效时将其送去墓地的监听效果。
function c30155789.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一编号，用于标记此卡发动所在的连锁，以便后续判断该连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成装备卡，给自己场上存在的1只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c30155789.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时的监听效果正式注册到当前玩家，使此次发动在连锁被无效时能够得到处理。
	Duel.RegisterEffect(e2,tp)
end
-- 当本卡发动所在的连锁被无效时，若本卡仍与该连锁相关，则将其送去墓地，避免其作为装备卡继续留在场上。
function c30155789.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的编号，用于确认被无效的正是本卡发动的那个连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 检查对象是否合法（己方场上的表侧怪兽），并在发动检查时确认已经支付代价且场上存在至少1只可装备的表侧怪兽。
function c30155789.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return e:IsCostChecked()
		-- 确认存在至少1只己方场上表侧表示怪兽能成为此卡的装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择装备目标的提示信息（请选择要装备的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只己方场上表侧表示怪兽，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本连锁的操作信息：本效果属于装备类别，预定装备的卡是本卡，数量为1，以便其他卡能够正确认识并响应这个装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：确认此卡仍在魔陷区且与效果关联后，在对象怪兽仍合法时把此卡装备给它；随后注册造成效果伤害时加攻的诱发效果和装备限制效果；若对象不合法则将此卡送去墓地。
function c30155789.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备到对象怪兽的装备区。
		Duel.Equip(tp,c,tc)
		-- 这张卡的控制者用卡的效果给与对方玩家伤害的场合，直到那个回合的结束阶段时装备怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_DAMAGE)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c30155789.damcon)
		e1:SetOperation(c30155789.damop)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 给自己场上存在的1只怪兽装备。
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
-- 判定装备对象是否合法：必须是本卡当前装备的怪兽，或者是本卡控制者场上的怪兽。
function c30155789.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
-- 符合条件：本卡控制者用卡的效果给与对方玩家伤害（伤害原因含效果伤害，受伤者为对方，伤害来源控制者为自己）。
function c30155789.damcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep~=tp and rp==tp
end
-- 效果处理：取得装备怪兽，为其添加直到结束阶段攻击力上升1000的效果。
function c30155789.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	-- 直到那个回合的结束阶段时装备怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
