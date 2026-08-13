--氷結界の軍師
-- 效果：
-- ①：1回合1次，从手卡把1只「冰结界」怪兽送去墓地才能发动。自己抽1张。
function c50032342.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「冰结界」怪兽送去墓地才能发动。自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50032342,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c50032342.cost)
	e1:SetTarget(c50032342.target)
	e1:SetOperation(c50032342.operation)
	c:RegisterEffect(e1)
end
-- 代价过滤器：若候选卡在手牌，则要求是「冰结界」怪兽且可作为代价送去墓地；若候选卡在墓地，则要求发动者本身是「冰结界」怪兽、候选卡可除外且拥有特定效果（18319762）作为替代代价。
function c50032342.cfilter(c,e,tp)
	if c:IsLocation(LOCATION_HAND) then
		return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
	else
		return e:GetHandler():IsSetCard(0x2f) and c:IsAbleToRemove() and c:IsHasEffect(18319762,tp)
	end
end
-- 支付代价处理：先确认存在合法代价卡，再让玩家选择1张手牌或墓地中的卡；若选中的是拥有特殊替代效果的墓地卡，则将其除外并消耗该效果次数，否则直接送去墓地。
function c50032342.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认是否至少存在1张满足过滤条件的卡可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c50032342.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出提示，请玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌或墓地中精确选择1张满足条件的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c50032342.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local te=tc:IsHasEffect(18319762,tp)
	if te then
		te:UseCountLimit(tp)
		-- 若选择的是墓地中带有特殊替代效果的卡，则将其表侧除外，并代替送墓作为代价。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
	else
		-- 若选择的是手牌中的「冰结界」怪兽，则将其送去墓地作为代价。
		Duel.SendtoGrave(tc,REASON_COST)
	end
end
-- 发动目标设定与合法性检查：确认玩家可以抽卡，然后记录目标玩家和抽卡张数，并设置操作信息。
function c50032342.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动者玩家是否可以进行1张抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次效果的目标玩家设置为发动者（tp）。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的参数设置为1，即抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：这是一个抽卡效果，目标玩家为tp，预计处理1张抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理阶段：获取之前设定的目标玩家和抽卡张数，并实际执行抽卡。
function c50032342.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和参数，作为实际抽卡的玩家和张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽取指定数量的卡，原因标记为效果（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
