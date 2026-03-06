--ガガガドロー
-- 效果：
-- 把自己墓地3只名字带有「我我我」的怪兽从游戏中除外才能发动。从卡组抽2张卡。
function c21831848.initial_effect(c)
	-- 创建效果，设置为发动时点，具有抽卡效果，需要指定玩家为目标，发动方式为自由时点，设置费用、目标和效果处理函数
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
-- 过滤函数，用于筛选墓地里名字带有「我我我」的怪兽，且可以作为除外的代价
function c21831848.filter(c)
	return c:IsSetCard(0x54) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 费用处理函数，检查是否满足除外3只「我我我」怪兽的条件，若满足则提示选择并除外这些卡
function c21831848.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否满足除外3只「我我我」怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21831848.filter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的3张卡
	local g=Duel.SelectMatchingCard(tp,c21831848.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 将选中的卡从游戏中除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标处理函数，检查玩家是否可以抽2张卡，若满足则设置目标玩家和抽卡数量
function c21831848.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数，获取连锁中的目标玩家和抽卡数量并执行抽卡效果
function c21831848.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
