--サイバー・ウロボロス
-- 效果：
-- 这张卡从游戏中除外时，可以把手卡1张卡送去墓地，从卡组抽1张卡。
function c30042158.initial_effect(c)
	-- 这张卡从游戏中除外时，可以把手卡1张卡送去墓地，从卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30042158,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCost(c30042158.cost)
	e1:SetTarget(c30042158.target)
	e1:SetOperation(c30042158.operation)
	c:RegisterEffect(e1)
end
-- 定义代价函数：效果发动前需从手卡丢弃1张卡作为代价，并检查是否满足代价条件。
function c30042158.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动的合法性检查阶段，确认己方手卡中是否存在1张能作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 正式发动时，从手卡挑选1张能作为代价的卡丢弃去墓地，丢弃原因记为代价。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 定义效果处理的目标设定函数：确定抽卡对象玩家和抽卡数量，并设置操作信息。
function c30042158.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检查阶段，确认己方玩家能否进行抽卡，且抽卡数量为1。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的目标玩家设为己方玩家，即抽卡方为效果发动者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本连锁效果涉及抽卡分类，处理时预计让己方玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果处理时的实际操作：从连锁信息中取出目标玩家和抽卡数量，执行抽卡。
function c30042158.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前保存的目标玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽取指定数量的卡，完成抽卡操作。
	Duel.Draw(p,d,REASON_EFFECT)
end
