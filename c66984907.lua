--A・∀・CC
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：以对方场上1张魔法·陷阱卡为对象才能发动。那张卡和这张卡送去墓地。
-- ●对方：从卡组把1只「惊乐」怪兽加入手卡，这张卡送去墓地。
function c66984907.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c66984907.cost)
	e1:SetTarget(c66984907.target)
	e1:SetOperation(c66984907.operation)
	c:RegisterEffect(e1)
	-- ●自己：以对方场上1张魔法·陷阱卡为对象才能发动。那张卡和这张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66984907,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_EQUIP+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,66984907)
	e2:SetCondition(c66984907.togcon)
	e2:SetTarget(c66984907.togtg)
	e2:SetOperation(c66984907.togop)
	c:RegisterEffect(e2)
	-- ●对方：从卡组把1只「惊乐」怪兽加入手卡，这张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66984907,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,66984907)
	e3:SetCondition(c66984907.thcon)
	e3:SetTarget(c66984907.thtg)
	e3:SetOperation(c66984907.thop)
	c:RegisterEffect(e3)
end
-- 发动时的Cost：使这张卡在发动后留在场上，并注册连锁被无效时的处理
function c66984907.cost(e,tp,eg,ep,ev,re,r,rp,chk)
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
	e2:SetOperation(c66984907.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在发动被无效时将此卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：取消送去墓地的确定状态，使其正常送去墓地
function c66984907.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：表侧表示的「惊乐」怪兽，或者对方场上的表侧表示怪兽
function c66984907.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 发动的靶向处理（Target）：检查并选择1只符合条件的怪兽作为对象
function c66984907.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c66984907.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在至少1只符合条件的怪兽可以作为对象
		and Duel.IsExistingTarget(c66984907.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c66984907.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置连锁信息：此效果包含装备操作，操作对象为自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动效果的处理（Operation）：将此卡作为装备卡装备给目标怪兽，若装备失败则送去墓地
function c66984907.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将此卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 这张卡当作装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c66984907.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给自身效果选择的怪兽，或者自己场上的「惊乐」怪兽、对方场上的怪兽
function c66984907.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 发动条件：装备怪兽的控制者是自己
function c66984907.togcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 效果②（自己）的靶向处理（Target）：选择对方场上1张魔法·陷阱卡作为对象，并设置送去墓地的连锁信息
function c66984907.togtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	g:AddCard(e:GetHandler())
	-- 设置连锁信息：将选中的卡和这张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 效果②（自己）的效果处理（Operation）：将作为对象的卡和这张卡送去墓地
function c66984907.togop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的魔法·陷阱卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		-- 将选中的卡和这张卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 发动条件：装备怪兽的控制者是对方
function c66984907.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(1-tp)
end
-- 过滤条件：卡组中的「惊乐」怪兽
function c66984907.thfilter(c)
	return c:IsSetCard(0x15b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②（对方）的靶向处理（Target）：检查卡组中是否存在「惊乐」怪兽，并设置检索和送去墓地的连锁信息
function c66984907.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「惊乐」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66984907.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息：将这张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 效果②（对方）的效果处理（Operation）：从卡组把1只「惊乐」怪兽加入手牌，并将这张卡送去墓地
function c66984907.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只「惊乐」怪兽
	local g=Duel.SelectMatchingCard(tp,c66984907.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
		if c:IsRelateToEffect(e) then
			-- 将这张卡送去墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end
