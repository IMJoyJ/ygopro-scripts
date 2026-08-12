--終わりの始まり
-- 效果：
-- ①：自己墓地有暗属性怪兽7只以上存在的场合，把那之内的5只除外才能发动。自己从卡组抽3张。
function c73680966.initial_effect(c)
	-- ①：自己墓地有暗属性怪兽7只以上存在的场合，把那之内的5只除外才能发动。自己从卡组抽3张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c73680966.condition)
	e1:SetCost(c73680966.cost)
	e1:SetTarget(c73680966.target)
	e1:SetOperation(c73680966.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自己墓地是否存在7只以上的暗属性怪兽
function c73680966.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少7只暗属性怪兽
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,7,nil,ATTRIBUTE_DARK)
end
-- 过滤条件：自己墓地的暗属性且可以除外的怪兽
function c73680966.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 发动代价：将自己墓地的5只暗属性怪兽除外
function c73680966.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查是否能将自己墓地的5只暗属性怪兽除外
	if chk==0 then return Duel.IsExistingMatchingCard(c73680966.cfilter,tp,LOCATION_GRAVE,0,5,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择5只暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c73680966.cfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	-- 将选中的5只怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标处理：确认是否能抽卡并设置抽卡参数
function c73680966.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查玩家是否可以效果抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 设置当前连锁的目标玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为3（抽卡数量）
	Duel.SetTargetParam(3)
	-- 设置效果处理的操作信息为：玩家抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理：执行抽卡
function c73680966.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
