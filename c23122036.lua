--陰謀の盾
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上1只怪兽装备。装备怪兽只要表侧攻击表示存在，1回合只有1次不会被战斗破坏。此外，装备怪兽的战斗发生的对自己的战斗伤害变成0。
function c23122036.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c23122036.cost)
	e1:SetTarget(c23122036.target)
	e1:SetOperation(c23122036.operation)
	c:RegisterEffect(e1)
end
-- 将此卡设为永续效果，使其在连锁处理后仍留在场上。
function c23122036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后不会因连锁无效而送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 设置一个连锁被无效时的处理效果，用于防止此卡被送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c23122036.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁无效时的处理效果注册给当前玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的处理函数，用于取消此卡送去墓地。
function c23122036.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 判断目标怪兽是否表侧表示。
function c23122036.filter(c)
	return c:IsFaceup()
end
-- 设置连锁目标为己方场上表侧表示的怪兽。
function c23122036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c23122036.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查己方场上是否存在表侧表示的怪兽。
		and Duel.IsExistingTarget(c23122036.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择己方场上表侧表示的1只怪兽作为装备对象。
	Duel.SelectTarget(tp,c23122036.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置此卡的发动信息为装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将此卡装备给选定的怪兽。
function c23122036.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetControler()==c:GetControler() then
		-- 将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 装备怪兽只要表侧攻击表示存在，1回合只有1次不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(c23122036.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备怪兽的战斗发生的对自己的战斗伤害变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetCondition(c23122036.damcon)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 限制此卡只能装备给特定怪兽。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c23122036.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 判断是否为战斗破坏且装备怪兽为表侧攻击表示。
function c23122036.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and e:GetHandler():GetEquipTarget():IsPosition(POS_FACEUP_ATTACK)
end
-- 判断装备怪兽是否为当前玩家控制。
function c23122036.damcon(e)
	return e:GetHandler():GetEquipTarget():GetControler()==e:GetHandlerPlayer()
end
-- 限制此卡只能装备给装备怪兽或当前玩家控制的怪兽。
function c23122036.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
