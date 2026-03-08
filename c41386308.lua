--マスマティシャン
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把1只4星以下的怪兽送去墓地。
-- ②：这张卡被战斗破坏送去墓地时才能发动。自己从卡组抽1张。
function c41386308.initial_effect(c)
	-- 效果原文：①：这张卡召唤成功时才能发动。从卡组把1只4星以下的怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41386308,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c41386308.target)
	e1:SetOperation(c41386308.operation)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡被战斗破坏送去墓地时才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41386308,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c41386308.drcon)
	e2:SetTarget(c41386308.drtg)
	e2:SetOperation(c41386308.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数：选择等级不超过4且可以送去墓地的怪兽
function c41386308.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAbleToGrave()
end
-- 效果处理时的判断函数：检查是否满足发动条件并设置操作信息
function c41386308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断条件：检查玩家场上是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c41386308.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要送去墓地的卡设置为操作对象
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：提示选择并执行将卡送去墓地的操作
function c41386308.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡组中的卡
	local g=Duel.SelectMatchingCard(tp,c41386308.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断条件函数：确认该卡是否因战斗破坏而进入墓地
function c41386308.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 设置抽卡效果的目标和参数
function c41386308.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断条件：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作对象为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置操作信息：将要抽卡的效果设置为操作对象
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理函数：根据连锁信息执行抽卡操作
function c41386308.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
