--みつこぶラクーダ
-- 效果：
-- 当自己场上存在3只表侧表示的「三峰驼」时，祭掉其中2只，就可以抽3张卡。
function c86988864.initial_effect(c)
	-- 当自己场上存在3只表侧表示的「三峰驼」时，祭掉其中2只，就可以抽3张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86988864,0))  --"抽卡"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c86988864.condition)
	e1:SetCost(c86988864.cost)
	e1:SetTarget(c86988864.target)
	e1:SetOperation(c86988864.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名为「三峰驼」的怪兽
function c86988864.cfilter(c)
	return c:IsFaceup() and c:IsCode(86988864)
end
-- 发动条件：自己场上存在3只表侧表示的「三峰驼」
function c86988864.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少3只表侧表示的「三峰驼」
	return Duel.IsExistingMatchingCard(c86988864.cfilter,tp,LOCATION_MZONE,0,3,nil)
end
-- 发动代价：解放自己场上2只表侧表示的「三峰驼」
function c86988864.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否存在至少2只可解放的「三峰驼」
	if chk==0 then return Duel.CheckReleaseGroup(tp,c86988864.cfilter,2,nil) end
	-- 选择自己场上2只表侧表示的「三峰驼」
	local g=Duel.SelectReleaseGroup(tp,c86988864.cfilter,2,2,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 发动目标：确认玩家是否能抽卡，并设置抽卡参数与操作信息
function c86988864.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己是否可以效果抽3张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为3
	Duel.SetTargetParam(3)
	-- 设置当前连锁的操作信息为：玩家抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 效果处理：执行抽卡
function c86988864.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
