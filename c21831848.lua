--ガガガドロー
-- 效果：
-- 把自己墓地3只名字带有「我我我」的怪兽从游戏中除外才能发动。从卡组抽2张卡。
function c21831848.initial_effect(c)
	-- 把自己墓地3只名字带有「我我我」的怪兽从游戏中除外才能发动。从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21831848.cost)
	e1:SetTarget(c21831848.target)
	e1:SetOperation(c21831848.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：检查卡是否为名字带有「我我我」的怪兽，并且可以作为代价从墓地除外。
function c21831848.filter(c)
	return c:IsSetCard(0x54) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：从自己墓地选择3只满足条件的「我我我」怪兽除外作为发动代价。
function c21831848.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己墓地是否存在至少3只满足条件的「我我我」怪兽，若存在则代价可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c21831848.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择3张满足条件的「我我我」怪兽，作为将要除外的代价卡。
	local g=Duel.SelectMatchingCard(tp,c21831848.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选择的3张「我我我」怪兽以表侧表示除外，计入发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动目标设定：确认自己能够抽2张卡，并记录对象玩家为自身、抽卡数量为2，同时设置抽卡的操作信息。
function c21831848.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：当前玩家是否可以抽2张卡，若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次连锁的对象玩家设置为发动者自身（tp），用于后续处理时确定抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 将本次连锁的对象参数设置为2，表示要抽取的卡数量为2。
	Duel.SetTargetParam(2)
	-- 设置操作信息：本次效果属于抽卡效果，预计让玩家tp抽2张卡（处理时需抽的卡数）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中取得对象玩家和抽卡数量，执行抽卡动作。
function c21831848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家（p）和对象参数（d，即抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p抽取d张卡，抽卡原因为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
