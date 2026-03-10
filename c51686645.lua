--捲怒重来
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以对方场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升500的装备卡使用给那只对方怪兽装备。
-- ②：装备怪兽从场上离开让这张卡被送去墓地的场合发动。自己从卡组抽1张。这张卡是这个回合发动的场合作为代替让以下效果适用。
-- ●自己从卡组抽2张，那之后选1张手卡丢弃。
function c51686645.initial_effect(c)
	-- ①：以对方场上1只表侧表示怪兽为对象才能把这张卡发动。这张卡当作攻击力·守备力上升500的装备卡使用给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c51686645.cost)
	e1:SetTarget(c51686645.target)
	e1:SetOperation(c51686645.activate)
	c:RegisterEffect(e1)
	-- ②：装备怪兽从场上离开让这张卡被送去墓地的场合发动。自己从卡组抽1张。这张卡是这个回合发动的场合作为代替让以下效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51686645,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,51686645)
	e2:SetCondition(c51686645.drcon)
	e2:SetTarget(c51686645.drtg)
	e2:SetOperation(c51686645.drop)
	c:RegisterEffect(e2)
end
-- 设置效果成本，使该卡在发动时不会因连锁被无效而直接送去墓地
function c51686645.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁ID以用于后续判断
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使该卡在发动后不会因连锁被无效而离开场外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个连锁被无效时的处理函数，防止效果被无效导致卡牌提前送去墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c51686645.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果e2注册给玩家tp，使其生效
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，检查是否为当前效果的连锁，并取消其送去墓地的操作
function c51686645.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID以进行判断
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 设置选择目标的条件：对方场上存在一张表侧表示的怪兽
function c51686645.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return e:IsCostChecked()
		-- 确保对方场上存在一张表侧表示的怪兽作为目标
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上的一只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表明将进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将该卡装备给指定目标怪兽
function c51686645.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(1-tp) then
		-- 将该卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备限制，确保只能装备给特定的怪兽或对方怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(c51686645.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备后攻击力上升500的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
		c:RegisterFlagEffect(51686645,RESET_EVENT+RESETS_STANDARD-RESET_LEAVE-RESET_TOGRAVE+RESET_PHASE+PHASE_END,0,1)
	else
		c:CancelToGrave(false)
	end
end
-- 定义装备限制函数，确保只有指定怪兽可以被装备
function c51686645.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or c:IsControler(1-e:GetHandlerPlayer())
end
-- 判断该卡因失去装备对象而送去墓地，并且装备对象不在场上或叠放区
function c51686645.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_LOST_TARGET)
		and not e:GetHandler():GetPreviousEquipTarget():IsLocation(LOCATION_ONFIELD+LOCATION_OVERLAY)
end
-- 根据是否为本回合发动的场合作为代替效果，决定抽卡数量和丢弃手牌数量
function c51686645.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetFlagEffect(51686645)>0 then
		e:SetLabel(1)
		-- 设置操作信息，表示将从卡组抽2张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		-- 设置操作信息，表示之后需要选择1张手卡丢弃
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	else
		e:SetLabel(0)
		-- 设置操作信息，表示将从卡组抽1张卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
-- 执行效果处理，根据是否为本回合发动的场合决定抽卡和丢弃手牌的数量
function c51686645.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 进行抽2张卡的操作，若成功则继续后续处理
		if Duel.Draw(tp,2,REASON_EFFECT)~=0 then
			-- 将玩家的手卡洗切
			Duel.ShuffleHand(tp)
			-- 中断当前效果处理，使之后的效果视为不同时处理
			Duel.BreakEffect()
			-- 让玩家从手牌中丢弃1张牌
			Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	else
		-- 进行抽1张卡的操作
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
