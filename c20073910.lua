--天照大神
-- 效果：
-- 这张卡不能召唤·特殊召唤。
-- ①：里侧表示的这只怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡变成表侧守备表示才能发动。自己从卡组抽1张。
-- ②：这张卡反转的场合发动。这张卡以外的场上的卡全部除外。
-- ③：这张卡反转的回合的结束阶段发动。这张卡回到持有者手卡。
function c20073910.initial_effect(c)
	-- 为这张卡添加灵魂怪兽效果，在翻转时回到手卡
	aux.EnableSpiritReturn(c,EVENT_FLIP)
	-- 这张卡不能召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e1)
	-- 这张卡不能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置这张卡不能特殊召唤
	e2:SetValue(aux.FALSE)
	c:RegisterEffect(e2)
	-- ①：里侧表示的这只怪兽为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡变成表侧守备表示才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c20073910.condition)
	e3:SetCost(c20073910.cost)
	e3:SetTarget(c20073910.target)
	e3:SetOperation(c20073910.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡反转的场合发动。这张卡以外的场上的卡全部除外。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_FLIP)
	e4:SetTarget(c20073910.thtg)
	e4:SetOperation(c20073910.thop)
	c:RegisterEffect(e4)
end
-- 效果发动条件：对方发动了以这张卡为对象的魔法·陷阱·怪兽效果且这张卡为里侧表示
function c20073910.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(e:GetHandler()) and e:GetHandler():IsFacedown()
end
-- 效果处理费用：将这张卡变为表侧守备表示
function c20073910.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这张卡变为表侧守备表示
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
-- 效果处理目标：准备抽一张卡
function c20073910.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的对象参数为1
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理运算：执行抽卡操作
function c20073910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 效果处理目标：准备除外场上的卡
function c20073910.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索场上所有可以除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	-- 设置效果操作信息为除外效果
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理运算：执行除外操作
function c20073910.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上所有可以除外的卡（排除自身）
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将指定卡片组以表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
