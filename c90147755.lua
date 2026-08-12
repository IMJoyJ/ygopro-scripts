--炎の女暗殺者
-- 效果：
-- 反转：自己的卡组最上面的3张卡在游戏中除外。对方受到800分的伤害。
function c90147755.initial_effect(c)
	-- 反转：自己的卡组最上面的3张卡在游戏中除外。对方受到800分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90147755,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCost(c90147755.cost)
	e1:SetTarget(c90147755.target)
	e1:SetOperation(c90147755.operation)
	c:RegisterEffect(e1)
end
-- 代价过滤函数：将自己卡组最上方的3张卡除外
function c90147755.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己卡组是否至少有3张可以作为代价除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_DECK,0,3,nil) end
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	-- 使接下来的操作不触发卡组洗牌检测
	Duel.DisableShuffleCheck()
	-- 将获取的3张卡以表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的目标确认与操作信息注册
function c90147755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为800
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为给对方造成800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理函数：给对方造成800点伤害
function c90147755.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
