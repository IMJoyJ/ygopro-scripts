--岩投げアタック
-- 效果：
-- 选择自己卡组1只岩石族怪兽送去墓地。给与对方基本分500分的伤害。之后洗切卡组。
function c20781762.initial_effect(c)
	-- 效果原文内容：选择自己卡组1只岩石族怪兽送去墓地。给与对方基本分500分的伤害。之后洗切卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20781762,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c20781762.cost)
	e1:SetTarget(c20781762.target)
	e1:SetOperation(c20781762.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选卡组中可以作为代价送去墓地的岩石族怪兽
function c20781762.cfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGraveAsCost()
end
-- 效果处理的代价函数，检查是否满足条件并选择一张岩石族怪兽送去墓地
function c20781762.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在至少1张满足条件的岩石族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c20781762.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张岩石族怪兽
	local g=Duel.SelectMatchingCard(tp,c20781762.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的岩石族怪兽送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理的目标函数，设置伤害对象和伤害值
function c20781762.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为对对方造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理的发动函数，执行对对方造成伤害的操作
function c20781762.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
