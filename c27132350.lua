--ファイヤーソーサラー
-- 效果：
-- 反转：自己的手卡随机选2张除外。对方受到800分的伤害。
function c27132350.initial_effect(c)
	-- 反转：自己的手卡随机选2张除外。对方受到800分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27132350,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCost(c27132350.cost)
	e1:SetTarget(c27132350.target)
	e1:SetOperation(c27132350.operation)
	c:RegisterEffect(e1)
end
-- 定义反转效果的费用处理：先确认手牌中有至少2张可除外的卡，再随机选2张除外作为发动代价。
function c27132350.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）判断自己手牌是否存在至少2张可以除外作为代价的卡，用于决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,2,nil) end
	-- 获取自己手牌中所有可作为代价除外的卡，组成一个卡片集合供随机选取。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,nil)
	local rg=g:RandomSelect(tp,2)
	-- 将随机选出的2张手牌以表侧表示除外，作为效果发动所支付的代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 定义效果发动时的目标设定部分：本效果不取对象，但需将对玩家指定为伤害对象，设置伤害值为800，并登记操作信息。
function c27132350.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），表示伤害由对方承受。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的参数设置为800，表示造成的伤害数值为800。
	Duel.SetTargetParam(800)
	-- 登记本次操作信息：对对方玩家造成800点伤害（CATEGORY_DAMAGE），供其他卡片效果连锁时检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 定义效果实际处理阶段：读取之前保存的玩家与伤害参数，并对该玩家造成效果伤害。
function c27132350.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和伤害参数，分别赋值给p与d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害，即对对方造成800点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
