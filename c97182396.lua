--A・∀・VV
-- 效果：
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：1回合1次，对方怪兽的攻击宣言时才能发动。那次攻击无效，直到战斗阶段结束时装备怪兽的控制权变更。
-- ●对方：装备怪兽把效果发动时才能发动。装备怪兽回到持有者手卡。
function c97182396.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c97182396.cost)
	e1:SetTarget(c97182396.target)
	e1:SetOperation(c97182396.operation)
	c:RegisterEffect(e1)
	-- ●自己：1回合1次，对方怪兽的攻击宣言时才能发动。那次攻击无效，直到战斗阶段结束时装备怪兽的控制权变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97182396,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c97182396.nacon)
	e2:SetTarget(c97182396.natg)
	e2:SetOperation(c97182396.naop)
	c:RegisterEffect(e2)
	-- ●对方：装备怪兽把效果发动时才能发动。装备怪兽回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97182396,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c97182396.thcon)
	e3:SetTarget(c97182396.thtg)
	e3:SetOperation(c97182396.thop)
	c:RegisterEffect(e3)
end
-- 发动的准备工作（cost）：设置卡片发动后留在场上，并注册连锁被无效时送去墓地的效果
function c97182396.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c97182396.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁被无效时将卡片送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：如果该卡在连锁中，则取消其留在场上的状态并送去墓地
function c97182396.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：场上表侧表示的自己场上的「惊乐」怪兽或者对方场上的怪兽
function c97182396.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 效果①的发动准备（target）：选择1只符合条件的怪兽作为对象
function c97182396.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c97182396.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 判断场上是否存在可以作为装备对象的怪兽
		and Duel.IsExistingTarget(c97182396.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c97182396.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息：装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（operation）：将此卡装备给目标怪兽，并设置装备限制
function c97182396.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将此卡作为装备卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 这张卡当作装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c97182396.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给符合条件的怪兽（自己场上的「惊乐」怪兽或对方场上的怪兽）
function c97182396.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 效果②（自己控制时）的发动条件：对方怪兽攻击宣言时，且装备怪兽由自己控制
function c97182396.nacon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动攻击的怪兽
	local at=Duel.GetAttacker()
	local ec=e:GetHandler():GetEquipTarget()
	return at:IsControler(1-tp) and ec and ec:IsControler(tp)
end
-- 效果②（自己控制时）的发动准备（target）：确认装备怪兽可以改变控制权
function c97182396.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsControlerCanBeChanged() end
	-- 设置效果处理信息：转移装备怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,ec,1,0,0)
end
-- 效果②（自己控制时）的效果处理（operation）：使攻击无效，并转移装备怪兽的控制权
function c97182396.naop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 尝试无效攻击，若成功且装备怪兽存在则继续处理
	if Duel.NegateAttack()~=0 and ec then
		-- 直到战斗阶段结束时，装备怪兽的控制权变更
		Duel.GetControl(ec,1-ec:GetControler(),PHASE_BATTLE,1)
	end
end
-- 效果②（对方控制时）的发动条件：装备怪兽发动效果时，且装备怪兽由对方控制
function c97182396.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetHandler():GetEquipTarget()
	local rc=re:GetHandler()
	return ec and ec:IsControler(1-tp) and ec==rc and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②（对方控制时）的发动准备（target）：确认装备怪兽可以回到手卡
function c97182396.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsAbleToHand() end
	-- 设置效果处理信息：装备怪兽回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,ec,1,0,0)
end
-- 效果②（对方控制时）的效果处理（operation）：将装备怪兽送回持有者手卡
function c97182396.thop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsAbleToHand() then
		-- 将装备怪兽送回持有者的手卡
		Duel.SendtoHand(ec,nil,REASON_EFFECT)
	end
end
