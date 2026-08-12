--妖仙獣 飯綱鞭
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。这个回合，在「妖仙兽」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：自己场上有其他的「妖仙兽」怪兽存在的场合才能发动。自己从卡组抽1张。
-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
function c85970321.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。这个回合，在「妖仙兽」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,85970321)
	e1:SetCost(c85970321.cost)
	e1:SetOperation(c85970321.operation)
	c:RegisterEffect(e1)
	-- ②：自己场上有其他的「妖仙兽」怪兽存在的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,85970322)
	e2:SetCondition(c85970321.drcon)
	e2:SetTarget(c85970321.drtg)
	e2:SetOperation(c85970321.drop)
	c:RegisterEffect(e2)
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(c85970321.regop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价：把手牌的这张卡丢弃
function c85970321.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果的处理：注册在「妖仙兽」怪兽召唤·特殊召唤成功时限制对方发动的效果
function c85970321.operation(e,tp,eg,ep,ev,re,r,rp)
	-- ①：把这张卡从手卡丢弃才能发动。这个回合，在「妖仙兽」怪兽的召唤·特殊召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。②：自己场上有其他的「妖仙兽」怪兽存在的场合才能发动。自己从卡组抽1张。③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c85970321.sumcon)
	e1:SetOperation(c85970321.sumsuc)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：在通常召唤成功时触发限制对方发动的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 注册全局效果：在特殊召唤成功时触发限制对方发动的效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：表侧表示的「妖仙兽」怪兽
function c85970321.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 触发条件：召唤·特殊召唤成功的怪兽中存在表侧表示的「妖仙兽」怪兽
function c85970321.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85970321.filter,1,nil)
end
-- 效果处理：限制对方在连锁结束前发动卡的效果
function c85970321.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设定直到连锁结束为止的连锁限制
	Duel.SetChainLimitTillChainEnd(c85970321.efun)
end
-- 连锁限制函数：只有自己可以发动效果（对方不能发动效果）
function c85970321.efun(e,ep,tp)
	return ep==tp
end
-- 过滤条件：表侧表示的「妖仙兽」怪兽
function c85970321.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- ②效果的发动条件：自己场上有其他的「妖仙兽」怪兽存在
function c85970321.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除自身以外的表侧表示「妖仙兽」怪兽
	return Duel.IsExistingMatchingCard(c85970321.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- ②效果的靶向：确认玩家是否能抽卡，并设置抽卡参数和操作信息
function c85970321.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测可行性阶段，则检查自己是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理：自己从卡组抽1张卡
function c85970321.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ③效果的注册：在召唤成功的结束阶段注册让这张卡回到持有者手卡的效果
function c85970321.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡召唤的回合的结束阶段发动。这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c85970321.rettg)
	e1:SetOperation(c85970321.retop)
	e1:SetReset(RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ③效果的靶向：设置回到手卡的操作信息
function c85970321.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为：将这张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果的处理：将这张卡回到持有者手卡
function c85970321.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 因效果将这张卡送回持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
