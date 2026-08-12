--王の支配
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方连锁自己的「王战」卡的效果的发动把魔法·陷阱·怪兽的效果发动时，丢弃1张手卡才能发动。那个对方的效果变成「双方玩家各自从卡组抽1张」。
function c64325438.initial_effect(c)
	-- 「王战的支配」卡片的发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64325438,0))  --"发动但不使用效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方连锁自己的「王战」卡的效果的发动把魔法·陷阱·怪兽的效果发动时，丢弃1张手卡才能发动。那个对方的效果变成「双方玩家各自从卡组抽1张」
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64325438,1))  --"改变对方效果"
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,64325438)
	e2:SetCondition(c64325438.chcon)
	e2:SetCost(c64325438.chcost)
	e2:SetOperation(c64325438.chop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
end
-- 检查是否满足发动条件：对方连锁自己发动的「王战」卡的效果发动了魔法·陷阱·怪兽的效果，且双方玩家当前都能抽卡
function c64325438.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的连锁序号
	local ct=Duel.GetCurrentChain()
	if ct<2 then return end
	-- 检查双方玩家是否都可以从卡组抽卡，若有任意一方不能抽卡则不能发动
	if not Duel.IsPlayerCanDraw(tp,1) or not Duel.IsPlayerCanDraw(1-tp,1) then return false end
	-- 获取当前连锁的前一个连锁（即被对方连锁的那个效果）的效果和发动玩家
	local te,p=Duel.GetChainInfo(ct-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return te and te:GetHandler():IsSetCard(0x134) and p==tp and rp==1-tp
end
-- 发动代价（Cost）：丢弃1张手卡
function c64325438.chcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查手牌中是否存在至少1张可以丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果处理：将对方连锁的效果替换为“双方玩家各自从卡组抽1张”，并清空该效果的对象
function c64325438.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将对方发动的效果的对象清空（防止原效果中含有需要处理的对象导致异常）
	Duel.ChangeTargetCard(ev,g)
	-- 将对方发动的效果的处理函数替换为指定的抽卡效果处理函数
	Duel.ChangeChainOperation(ev,c64325438.repop)
end
-- 替换后的效果处理函数：双方玩家各自从卡组抽1张卡
function c64325438.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 让自身玩家因效果从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家因效果从卡组抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
