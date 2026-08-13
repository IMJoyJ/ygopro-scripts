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
-- 发动时作为誓约代价：获取当前连锁ID，为本卡附加发动后留在场上的效果（EFFECT_REMAIN_FIELD+OATH+RESET_CHAIN），并注册一个连锁被无效时让本卡正确送去墓地的持续效果。
function c23122036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于标识本次发动，以便后续在连锁被无效时判断是否与本卡相关。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 给自己场上1只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c23122036.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时把本卡送去墓地的效果注册到场上（监听EVENT_CHAIN_DISABLED），用于处理发动被无效后的送墓。
	Duel.RegisterEffect(e2,tp)
end
-- 处理连锁被无效的场合：比较被无效的连锁ID是否为本卡发动时的连锁，若是且本卡仍与该连锁相关，则解除留场状态并让本卡正常送去墓地。
function c23122036.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，用于判断被无效的是否是本卡发动的连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 装备对象过滤函数：只选择场上表侧表示的怪兽。
function c23122036.filter(c)
	return c:IsFaceup()
end
-- 发动时选择自己场上1只表侧表示的怪兽作为装备对象，并确认本卡发动时已支付cost且存在合法对象。
function c23122036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c23122036.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 确认自己场上存在至少1只满足条件的表侧表示怪兽，且该怪兽可被选择为对象。
		and Duel.IsExistingTarget(c23122036.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧表示怪兽，并将其登记为这张卡效果的对象。
	Duel.SelectTarget(tp,c23122036.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将操作信息设为装备分类并指定对象为本卡自身，使相关卡（如星尘龙等）能正确响应该装备行为。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：若本卡仍在魔陷区、与发动效果关联且未处于连锁结束后离场状态，则取得对象；确认对象仍关联、表侧表示且控制权未变后，将本卡装备给该怪兽，并注册本卡作为装备卡时赋予的“装备怪兽1回合1次不被战斗破坏”“对装备怪兽战斗伤害变为0”及装备限制效果；若条件不满足，则解除留场状态并让本卡正常送去墓地。
function c23122036.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得效果处理时的装备对象（发动时选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetControler()==c:GetControler() then
		-- 将本卡作为装备卡装备到对象怪兽上。
		Duel.Equip(tp,c,tc)
		-- 装备怪兽只要表侧攻击表示存在，1回合只有1次不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetCountLimit(1)
		e1:SetValue(c23122036.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 此外，装备怪兽的战斗发生的对自己的战斗伤害变成0。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetCondition(c23122036.damcon)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给自己场上1只怪兽装备。
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
-- 判定是否满足‘表侧攻击表示存在且被战斗破坏’这一条件，若满足则保留当次不被战斗破坏的效果。
function c23122036.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and e:GetHandler():GetEquipTarget():IsPosition(POS_FACEUP_ATTACK)
end
-- 判定装备怪兽的控制者是否为这张装备卡的控制者，满足时才适用对自己战斗伤害为0的效果。
function c23122036.damcon(e)
	return e:GetHandler():GetEquipTarget():GetControler()==e:GetHandlerPlayer()
end
-- 判定可作为装备对象的卡：必须是当前装备的怪兽，或由这张装备卡的控制者控制的怪兽（即只能装备在自己场上）。
function c23122036.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(e:GetHandlerPlayer())
end
