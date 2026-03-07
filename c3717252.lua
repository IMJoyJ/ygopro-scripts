--シャドール・ビースト
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。自己抽2张。那之后，选自己1张手卡丢弃。
-- ②：这张卡被效果送去墓地的场合才能发动。自己抽1张。
function c3717252.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。自己抽2张。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3717252,0))  --"抽2张卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,3717252)
	e1:SetCost(c3717252.cost)
	e1:SetTarget(c3717252.target)
	e1:SetOperation(c3717252.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3717252,1))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,3717252)
	e2:SetCondition(c3717252.drcon)
	e2:SetCost(c3717252.cost)
	e2:SetTarget(c3717252.drtg)
	e2:SetOperation(c3717252.drop)
	c:RegisterEffect(e2)
	c3717252.shadoll_flip_effect=e1
end
-- 效果发动时的费用处理函数
function c3717252.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示本效果被发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的发动时的处理函数
function c3717252.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为2
	Duel.SetTargetParam(2)
	-- 设置效果处理信息为抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置效果处理信息为丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的发动效果处理函数
function c3717252.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家的信息
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 执行抽2张卡的效果并判断是否成功抽到2张
	if Duel.Draw(p,2,REASON_EFFECT)==2 then
		-- 将当前玩家的手卡洗牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 效果②发动的条件函数，判断是否因效果送入墓地
function c3717252.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果②的发动时的处理函数
function c3717252.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息为抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的发动效果处理函数
function c3717252.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和参数的信息
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
