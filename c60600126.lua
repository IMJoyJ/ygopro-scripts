--エマージェンシー・サイバー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「电子龙」怪兽或者不能通常召唤的机械族·光属性怪兽加入手卡。
-- ②：对方让这张卡的发动无效，这张卡被送去墓地的场合，丢弃1张手卡才能发动。这张卡加入手卡。
function c60600126.initial_effect(c)
	-- ①：从卡组把1只「电子龙」怪兽或者不能通常召唤的机械族·光属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,60600126+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c60600126.negreg)
	e1:SetTarget(c60600126.target)
	e1:SetOperation(c60600126.activate)
	c:RegisterEffect(e1)
	-- ②：对方让这张卡的发动无效，这张卡被送去墓地的场合，丢弃1张手卡才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c60600126.thcon)
	e2:SetCost(c60600126.thcost)
	e2:SetTarget(c60600126.thtg)
	e2:SetOperation(c60600126.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CUSTOM+60600126)
	e3:SetCondition(c60600126.thcon2)
	c:RegisterEffect(e3)
end
-- 在发动时注册一个用于检测发动是否被对方无效的临时效果
function c60600126.negreg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	local c=e:GetHandler()
	-- 对方让这张卡的发动无效
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_NEGATED)
	e1:SetLabelObject(e)
	e1:SetOperation(c60600126.negcheck)
	e1:SetReset(RESET_CHAIN)
	-- 注册用于检测发动是否被对方无效的连锁内临时效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查当前连锁中本卡的发动是否被对方无效，若是则注册一个在连锁结束时触发自定义事件的效果
function c60600126.negcheck(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	-- 获取使连锁无效的效果以及无效该连锁的玩家
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if rp==tp and de and dp==1-tp and re==te then
		-- 对方让这张卡的发动无效，这张卡被送去墓地的场合，丢弃1张手卡才能发动。这张卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetOperation(c60600126.negevent)
		e1:SetLabelObject(te)
		-- 注册在连锁结束时触发自定义事件的临时效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 在连锁结束时，为被无效发动的本卡触发自定义事件，以便在墓地发动回收效果
function c60600126.negevent(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	-- 以本卡为事件卡触发自定义事件，通知系统本卡的发动已被无效
	Duel.RaiseEvent(te:GetHandler(),EVENT_CUSTOM+60600126,te,0,tp,tp,0)
	e:Reset()
end
-- 过滤卡组中「电子龙」怪兽或不能通常召唤的机械族·光属性怪兽
function c60600126.filter(c)
	return ((c:IsSetCard(0x1093) and c:IsType(TYPE_MONSTER)) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and not c:IsSummonableCard()))
		and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的靶向函数，检查卡组中是否存在符合条件的卡并设置操作信息
function c60600126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c60600126.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数，从卡组选择符合条件的卡加入手卡并给对方确认
function c60600126.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择加入手卡卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c60600126.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 墓地回收效果的触发条件，检查是否因对方使发动无效而送去墓地
function c60600126.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取无效该连锁的原因效果和无效该连锁的玩家
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	return rp==tp and de and dp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and e:GetHandler()==re:GetHandler() and e:GetHandler():GetReasonEffect()==de
end
-- 墓地回收效果的消耗函数，丢弃1张手卡
function c60600126.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 墓地回收效果的靶向函数，检查自身是否能加入手卡并设置操作信息
function c60600126.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 墓地回收效果的执行函数，将自身加入手卡
function c60600126.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身（墓地的这张卡）加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
-- 自定义事件触发时的条件函数，检查是否是本卡且没有导致送墓的效果（即因规则送墓）
function c60600126.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c==re:GetHandler() and c:GetReasonEffect()==nil
end
