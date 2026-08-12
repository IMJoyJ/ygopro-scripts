--ドドドドロー
-- 效果：
-- 把手卡或者自己场上表侧表示存在的1只名字带有「怒怒怒」的怪兽送去墓地才能发动。从卡组抽2张卡。「怒怒怒抽卡」在1回合只能发动1张。
function c73866096.initial_effect(c)
	-- 把手卡或者自己场上表侧表示存在的1只名字带有「怒怒怒」的怪兽送去墓地才能发动。从卡组抽2张卡。「怒怒怒抽卡」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,73866096+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c73866096.cost)
	e1:SetTarget(c73866096.target)
	e1:SetOperation(c73866096.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡或场上表侧表示的、可以作为代价送去墓地的「怒怒怒」怪兽
function c73866096.cfilter(c)
	return c:IsSetCard(0x82) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 发动代价：将手卡或自己场上表侧表示的1只「怒怒怒」怪兽送去墓地
function c73866096.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上是否存在至少1只满足条件的「怒怒怒」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73866096.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡或场上表侧表示的1只「怒怒怒」怪兽
	local g=Duel.SelectMatchingCard(tp,c73866096.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标处理：检查是否能抽卡，并设置抽卡玩家、抽卡数量及操作信息
function c73866096.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡
function c73866096.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
