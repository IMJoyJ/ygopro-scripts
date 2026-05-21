--闇の増産工場
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把自己的手卡·场上1只怪兽送去墓地才能发动。自己从卡组抽1张。
function c9064354.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把自己的手卡·场上1只怪兽送去墓地才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,9064354)
	e2:SetCost(c9064354.cost)
	e2:SetTarget(c9064354.target)
	e2:SetOperation(c9064354.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：手卡或场上的怪兽，且能作为代价送去墓地
function c9064354.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价处理：检查并选择自己手卡或场上的一只怪兽送去墓地
function c9064354.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9064354.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的手卡或场上选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c9064354.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选择的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 靶向与操作信息设置：检查玩家是否能抽卡，并设置抽卡参数
function c9064354.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：获取目标玩家和参数，执行抽卡
function c9064354.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
