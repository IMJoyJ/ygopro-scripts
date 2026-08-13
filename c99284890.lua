--壺魔神
-- 效果：
-- 将1张「强欲之壶」从手卡送去墓地。从自己的卡组抽3张卡。
function c99284890.initial_effect(c)
	-- 将1张「强欲之壶」从手卡送去墓地。从自己的卡组抽3张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99284890,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c99284890.cost)
	e1:SetTarget(c99284890.target)
	e1:SetOperation(c99284890.operation)
	c:RegisterEffect(e1)
end
-- 过滤出卡名为「强欲之壶」且可作为代价送去墓地的卡。
function c99284890.filter(c)
	return c:IsCode(55144522) and c:IsAbleToGraveAsCost()
end
-- 代价处理：确认手牌存在符合条件的「强欲之壶」后，将其丢弃作为发动代价。
function c99284890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查手牌中是否存在至少1张「强欲之壶」且可作为代价送入墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c99284890.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 选择1张手牌的「强欲之壶」丢弃作为代价。
	Duel.DiscardHand(tp,c99284890.filter,1,1,REASON_COST)
end
-- 发动目标设定：确认玩家可以抽3张卡，并将抽卡对象玩家和数量记录到连锁信息中。
function c99284890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：确认当前玩家可以抽3张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 将连锁的对象玩家设为发动玩家tp，表示抽卡的对象是tp。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设为3，表示抽卡数量为3。
	Duel.SetTargetParam(3)
	-- 登记操作信息：效果处理时将进行抽卡（CATEGORY_DRAW），对象为tp，数量为3，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理：根据连锁记录的对象玩家和参数，让该玩家抽对应数量的卡。
function c99284890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中记录的对象玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：让玩家p抽取d张卡，原因为效果（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
