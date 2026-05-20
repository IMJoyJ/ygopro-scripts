--鎖付き真紅眼牙
-- 效果：
-- ①：以自己场上1只「真红眼」怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
-- ②：把装备的这张卡送去墓地，以场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备卡使用给这张卡装备过的怪兽装备。只要这个效果把怪兽装备中，装备怪兽变成和那只怪兽相同的攻击力·守备力。
function c57135971.initial_effect(c)
	-- ①：以自己场上1只「真红眼」怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c57135971.cost)
	e1:SetTarget(c57135971.target)
	e1:SetOperation(c57135971.operation)
	c:RegisterEffect(e1)
	-- ②：把装备的这张卡送去墓地，以场上1只效果怪兽为对象才能发动。那只效果怪兽当作装备卡使用给这张卡装备过的怪兽装备。只要这个效果把怪兽装备中，装备怪兽变成和那只怪兽相同的攻击力·守备力。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCondition(c57135971.descon)
	e2:SetCost(c57135971.descost)
	e2:SetTarget(c57135971.destg)
	e2:SetOperation(c57135971.desop)
	c:RegisterEffect(e2)
end
-- ①的效果发动时的Cost，处理陷阱卡发动后留在场上的规则，以及被无效时送去墓地的处理
function c57135971.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 以自己场上1只「真红眼」怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c57135971.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁被无效时将卡送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的辅助操作：如果卡片仍与该连锁相关，则取消送去墓地的状态（使其正常送去墓地）
function c57135971.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤自己场上表侧表示的「真红眼」怪兽
function c57135971.filter(c)
	return c:IsSetCard(0x3b) and c:IsFaceup()
end
-- ①的效果发动时的对象选择与合法性检测
function c57135971.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c57135971.filter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return e:IsCostChecked()
		-- 检测自己场上是否存在可以作为装备对象的表侧表示「真红眼」怪兽
		and Duel.IsExistingTarget(c57135971.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「真红眼」怪兽作为效果对象
	Duel.SelectTarget(tp,c57135971.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表明此效果包含装备操作，操作对象为这张卡本身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ①的效果处理：将这张卡装备给目标怪兽，并赋予其最多2次向怪兽攻击的效果
function c57135971.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的「真红眼」怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c57135971.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给当前装备的怪兽，或者自己场上的「真红眼」怪兽
function c57135971.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x3b)
end
-- ②的效果发动条件：这张卡有装备怪兽，且不在伤害计算后
function c57135971.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测这张卡是否装备着怪兽，并确保当前时点不在伤害计算后
	return e:GetHandler():GetEquipTarget() and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- ②的效果Cost：记录当前装备的怪兽，并将这张卡送去墓地
function c57135971.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将这张卡送去墓地作为发动的Cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤场上表侧表示的效果怪兽
function c57135971.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ②的效果对象选择：选择场上1只效果怪兽（不能是原装备怪兽）作为对象
function c57135971.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c57135971.desfilter(chkc) and chkc~=tc end
	-- 检测场上是否存在除原装备怪兽以外的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c57135971.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler():GetEquipTarget()) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只效果怪兽作为对象，排除原装备怪兽
	local g=Duel.SelectTarget(tp,c57135971.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,tc)
	-- 设置连锁信息，表明此效果包含装备操作，操作对象为选择的效果怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- ②的效果处理：将目标效果怪兽装备给原装备怪兽，并使原装备怪兽的攻防变成与该怪兽相同
function c57135971.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取作为装备卡的目标效果怪兽
	local c=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将目标效果怪兽作为装备卡装备给原装备怪兽
		Duel.Equip(tp,c,tc)
		-- 只要这个效果把怪兽装备中，装备怪兽变成和那只怪兽相同的攻击力·守备力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 只要这个效果把怪兽装备中，装备怪兽变成和那只怪兽相同的攻击力·守备力。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(c:GetDefense())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 那只效果怪兽当作装备卡使用给这张卡装备过的怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c57135971.eqlimit2)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetLabelObject(tc)
		c:RegisterEffect(e3)
	end
end
-- 装备限制：只能装备给原「真红眼」装备怪兽
function c57135971.eqlimit2(e,c)
	return c==e:GetLabelObject()
end
