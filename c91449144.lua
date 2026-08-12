--ガスタの静寂 カーム
-- 效果：
-- 1回合1次，可以让自己墓地存在的2只名字带有「薰风」的怪兽回到卡组，从自己卡组抽1张卡。
function c91449144.initial_effect(c)
	-- 1回合1次，可以让自己墓地存在的2只名字带有「薰风」的怪兽回到卡组，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91449144,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c91449144.cost)
	e1:SetTarget(c91449144.target)
	e1:SetOperation(c91449144.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中可以作为代价回到卡组的「薰风」怪兽
function c91449144.filter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckAsCost()
end
-- 效果发动代价：将自己墓地2只「薰风」怪兽回到卡组
function c91449144.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2只满足条件的「薰风」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91449144.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择2只满足过滤条件的「薰风」怪兽
	local g=Duel.SelectMatchingCard(tp,c91449144.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 给选中的卡片显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡片作为发动代价送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果发动目标：验证玩家是否能抽卡，并注册抽卡相关的连锁信息
function c91449144.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以效果抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为当前回合玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数（抽卡张数）为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡效果
function c91449144.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
