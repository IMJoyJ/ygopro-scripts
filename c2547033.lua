--オルターガイスト・ホーンデッドロック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。「幻变骚灵」卡的效果盖放的这张卡在盖放的回合也能发动。
-- ①：作为这张卡的发动时的效果处理，从手卡把1只「幻变骚灵」怪兽送去墓地。
-- ②：对方把陷阱卡发动时，从手卡把1只「幻变骚灵」怪兽送去墓地才能发动。那个效果无效并破坏。
function c2547033.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从手卡把1只「幻变骚灵」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,2547033)
	e1:SetTarget(c2547033.target)
	e1:SetOperation(c2547033.operation)
	c:RegisterEffect(e1)
	-- ②：对方把陷阱卡发动时，从手卡把1只「幻变骚灵」怪兽送去墓地才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,2547034)
	e2:SetCondition(c2547033.discon)
	e2:SetCost(c2547033.discost)
	e2:SetTarget(c2547033.distg)
	e2:SetOperation(c2547033.disop)
	c:RegisterEffect(e2)
	-- 「幻变骚灵」卡的效果盖放的这张卡在盖放的回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2547033,1))  --"适用「幻变骚灵的闹鬼死锁」的效果来发动"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(c2547033.actcon)
	c:RegisterEffect(e3)
	if not c2547033.global_check then
		c2547033.global_check=true
		-- 用于记录「幻变骚灵」卡被盖放的事件
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c2547033.checkop)
		-- 将效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有「幻变骚灵」卡被盖放时，为该卡标记一个flag，用于后续判断是否可以发动效果
function c2547033.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re or not re:GetHandler():IsSetCard(0x103) then return end
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(2547033,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 过滤函数，用于筛选手牌中可以送去墓地的「幻变骚灵」怪兽
function c2547033.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x103) and c:IsAbleToGrave()
end
-- 设置效果发动时的处理信息，确定要处理的卡为手牌中的「幻变骚灵」怪兽
function c2547033.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手牌中是否存在至少1张「幻变骚灵」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2547033.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表示将要处理的卡为手牌中的1张怪兽卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 发动效果时的处理函数，提示玩家选择要送去墓地的「幻变骚灵」怪兽
function c2547033.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「幻变骚灵」怪兽
	local g=Duel.SelectMatchingCard(tp,c2547033.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断是否为对方发动的陷阱卡
function c2547033.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤函数，用于筛选手牌中可以作为代价送去墓地的「幻变骚灵」怪兽
function c2547033.discfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x103) and c:IsAbleToGraveAsCost()
end
-- 发动效果时的处理函数，提示玩家丢弃1张「幻变骚灵」怪兽作为代价
function c2547033.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即手牌中是否存在至少1张「幻变骚灵」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c2547033.discfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张「幻变骚灵」怪兽作为代价
	Duel.DiscardHand(tp,c2547033.discfilter,1,1,REASON_COST,nil)
end
-- 设置效果发动时的处理信息，确定要处理的卡为对方发动的陷阱卡
function c2547033.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要使对方发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将要破坏对方发动的陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 发动效果时的处理函数，使对方发动的效果无效并破坏该陷阱卡
function c2547033.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使对方发动的效果无效并确认该陷阱卡是否仍然存在
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏对方发动的陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断该卡是否在盖放的回合可以发动效果
function c2547033.actcon(e)
	return e:GetHandler():GetFlagEffect(2547033)>0
end
