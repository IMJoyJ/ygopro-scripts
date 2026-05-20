--魔導闇商人
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有永续魔法·永续陷阱卡存在，这张卡不会被战斗·效果破坏。
-- ②：对方回合，把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地才能发动。自己从卡组抽1张。
function c72171665.initial_effect(c)
	-- ①：只要自己场上有永续魔法·永续陷阱卡存在，这张卡不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c72171665.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：对方回合，把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地才能发动。自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72171665,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,72171665)
	e3:SetCondition(c72171665.drcon)
	e3:SetCost(c72171665.drcost)
	e3:SetTarget(c72171665.drtg)
	e3:SetOperation(c72171665.drop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示的永续魔法或永续陷阱卡
function c72171665.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS)
end
-- 破坏抗性效果的发生条件：自己场上存在永续魔法·永续陷阱卡
function c72171665.indcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己场上是否存在至少1张表侧表示的永续魔法·永续陷阱卡
	return Duel.IsExistingMatchingCard(c72171665.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 抽卡效果的发动条件：对方回合
function c72171665.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤条件：表侧表示且能作为代价送去墓地的永续魔法或永续陷阱卡
function c72171665.drfilter(c)
	return c72171665.cfilter(c) and c:IsAbleToGraveAsCost()
end
-- 抽卡效果的发动代价：把自己场上1张表侧表示的永续魔法·永续陷阱卡送去墓地
function c72171665.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可以作为代价送去墓地的表侧表示永续魔法·永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c72171665.drfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家发送选择要送去墓地的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张自己场上表侧表示的永续魔法·永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,c72171665.drfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 抽卡效果的发动准备（检查与设置操作信息）
function c72171665.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为“玩家抽1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理
function c72171665.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
