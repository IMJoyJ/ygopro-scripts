--ジェルゴンヌの終焉
-- 效果：
-- ①：以自己场上1只「廷达魔三角」连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会被战斗·效果破坏，不会成为对方的效果的对象。
-- ②：1回合1次，装备怪兽的全部连接标记的所向点有怪兽存在的场合才能发动。那些怪兽和这张卡全部破坏。全部破坏的场合，给与对方这张卡装备过的怪兽的攻击力数值的伤害。
function c59490397.initial_effect(c)
	-- ①：以自己场上1只「廷达魔三角」连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会被战斗·效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c59490397.cost)
	e1:SetTarget(c59490397.target)
	e1:SetOperation(c59490397.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，装备怪兽的全部连接标记的所向点有怪兽存在的场合才能发动。那些怪兽和这张卡全部破坏。全部破坏的场合，给与对方这张卡装备过的怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59490397,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c59490397.descon)
	e2:SetTarget(c59490397.destg)
	e2:SetOperation(c59490397.desop)
	c:RegisterEffect(e2)
end
-- 发动时的Cost处理，用于实现装备陷阱卡发动被无效时送去墓地的规则处理。
function c59490397.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只「廷达魔三角」连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽不会被战斗·效果破坏，不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c59490397.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在连锁被无效时将此卡送去墓地。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理，如果此卡仍与该连锁相关，则取消其送去墓地的状态。
function c59490397.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发事件的连锁的唯一标识ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤自己场上表侧表示的「廷达魔三角」连接怪兽。
function c59490397.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x10b)
end
-- 效果发动时的对象选择与可行性检查。
function c59490397.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59490397.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为装备对象的「廷达魔三角」连接怪兽。
		and Duel.IsExistingTarget(c59490397.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「廷达魔三角」连接怪兽作为效果的对象。
	Duel.SelectTarget(tp,c59490397.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息为装备此卡。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 定义装备限制，此卡只能装备给符合条件的「廷达魔三角」连接怪兽。
function c59490397.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_LINK) and c:IsSetCard(0x10b)
end
-- 效果处理，将此卡装备给目标怪兽，并赋予其战斗·效果破坏抗性以及不成为对方效果对象抗性。
function c59490397.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c59490397.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备怪兽不会被战斗·效果破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置抗性效果的值，使其不会成为对方的效果的对象。
		e4:SetValue(aux.tgoval)
		c:RegisterEffect(e4)
	else
		c:CancelToGrave(false)
	end
end
-- 检查装备怪兽的全部连接标记所指向的区域是否都有怪兽存在。
function c59490397.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:GetLinkedGroupCount()==tc:GetLink()
end
-- 效果发动时的目标确认，确定要破坏的卡片组，并设置破坏和伤害的操作信息。
function c59490397.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return tc:GetLinkedGroupCount()>0 end
	local lg=tc:GetLinkedGroup()
	lg:AddCard(e:GetHandler())
	-- 设置连锁的操作信息为破坏装备怪兽连接标记所指向的所有怪兽以及此卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,lg,lg:GetCount(),0,0)
	-- 设置连锁的操作信息为给与对方装备怪兽攻击力数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetAttack())
end
-- 效果处理，破坏装备怪兽连接标记所指向的所有怪兽和此卡，若全部破坏则给与对方装备怪兽攻击力数值的伤害。
function c59490397.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if not c:IsRelateToEffect(e) or not tc then return end
	local atk=tc:GetAttack()
	local lg=tc:GetLinkedGroup()
	lg:AddCard(c)
	local ct=lg:GetCount()
	if ct>0 then
		-- 破坏装备怪兽连接标记所指向的所有怪兽和此卡，并获取实际破坏的数量。
		local dc=Duel.Destroy(lg,REASON_EFFECT)
		if dc==ct then
			-- 给与对方玩家装备怪兽的攻击力数值的伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
