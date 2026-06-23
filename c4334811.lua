--スクラップ・リサイクラー
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只机械族怪兽送去墓地。
-- ②：1回合1次，让自己墓地2只机械族·地属性·4星怪兽回到卡组才能发动。自己从卡组抽1张。
function c4334811.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1只机械族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4334811,0))  --"选择1只机械族怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c4334811.target)
	e1:SetOperation(c4334811.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，让自己墓地2只机械族·地属性·4星怪兽回到卡组才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4334811,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c4334811.drcost)
	e3:SetTarget(c4334811.drtg)
	e3:SetOperation(c4334811.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选可以送去墓地的机械族怪兽
function c4334811.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息
function c4334811.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c4334811.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要处理的卡为1张送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并执行将卡送去墓地的操作
function c4334811.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c4334811.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于筛选可以返回卡组的机械族地属性4星怪兽
function c4334811.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsAbleToDeckAsCost()
end
-- 效果处理函数，选择并执行将卡返回卡组并抽卡的操作
function c4334811.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c4334811.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c4334811.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 显示选中卡的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡返回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果处理时的判断函数，检查是否满足发动条件并设置操作信息
function c4334811.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作对象玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置操作对象参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示将要处理的卡为1张抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行抽卡操作
function c4334811.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
