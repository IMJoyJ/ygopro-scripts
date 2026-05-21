--A・∀・WW
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：双方的主要阶段才能发动。选1张手卡回到卡组最下面。那之后，自己从卡组抽1张。
-- ●对方：装备怪兽的攻击力·守备力直到回合结束时交换。
function c93473606.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c93473606.cost)
	e1:SetTarget(c93473606.target)
	e1:SetOperation(c93473606.operation)
	c:RegisterEffect(e1)
	-- ●自己：双方的主要阶段才能发动。选1张手卡回到卡组最下面。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93473606,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,93473606)
	e2:SetCondition(c93473606.drcon)
	e2:SetTarget(c93473606.drtg)
	e2:SetOperation(c93473606.drop)
	c:RegisterEffect(e2)
	-- ●对方：装备怪兽的攻击力·守备力直到回合结束时交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93473606,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,93473606)
	e3:SetCondition(c93473606.swcon)
	e3:SetTarget(c93473606.swtg)
	e3:SetOperation(c93473606.swop)
	c:RegisterEffect(e3)
end
-- 定义卡片发动时的代价，注册使这张卡留在场上以及连锁被无效时送去墓地的效果
function c93473606.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
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
	e2:SetOperation(c93473606.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 在全局环境注册该连锁无效时处理的事件效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：如果卡片仍在连锁中，则取消送去墓地（使其正常送去墓地）
function c93473606.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤场上的表侧表示怪兽：自己场上的「惊乐」怪兽或者对方场上的怪兽
function c93473606.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 卡片发动时的对象选择与操作信息设置
function c93473606.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c93473606.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在至少1只满足条件的怪兽作为装备对象
		and Duel.IsExistingTarget(c93473606.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只满足条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c93473606.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置当前连锁的操作信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动时的效果处理：将这张卡装备给目标怪兽，并添加装备限制
function c93473606.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡作为装备卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 这张卡当作装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c93473606.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给当前装备的怪兽，或者自己场上的「惊乐」怪兽、对方场上的怪兽
function c93473606.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 效果②（自己控制）的发动条件：装备怪兽由自己控制，且在双方的主要阶段
function c93473606.drcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ec and ec:IsControler(tp) and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 效果②（自己控制）的发动准备：检查手卡并设置回卡组和抽卡的操作信息
function c93473606.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡是否有可以回到卡组的卡，且自己是否可以抽卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的操作信息为将1张手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置当前连锁的操作信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②（自己控制）的效果处理：选1张手卡回到卡组最下面，然后抽1张卡
function c93473606.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己手卡中1张可以回到卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选择的卡送回卡组最下面，并确认其已成功回到卡组
	if tc and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		-- 中断当前效果，使后续的抽卡处理与回卡组处理不视为同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 效果②（对方控制）的发动条件：装备怪兽由对方控制，且不在伤害计算后
function c93473606.swcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 检查装备怪兽是否由对方控制，且当前时点是否满足伤害步骤的发动限制
	return ec and ec:IsControler(1-tp) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果②（对方控制）的发动准备：检查装备怪兽是否存在且具有守备力
function c93473606.swtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsDefenseAbove(0) end
end
-- 效果②（对方控制）的效果处理：将装备怪兽的攻击力与守备力直到回合结束时交换
function c93473606.swop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		local atk=ec:GetAttack()
		local def=ec:GetDefense()
		-- ●对方：装备怪兽的攻击力·守备力直到回合结束时交换。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(def)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(atk)
		ec:RegisterEffect(e2)
	end
end
