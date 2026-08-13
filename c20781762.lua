--岩投げアタック
-- 效果：
-- 选择自己卡组1只岩石族怪兽送去墓地。给与对方基本分500分的伤害。之后洗切卡组。
function c20781762.initial_effect(c)
	-- 选择自己卡组1只岩石族怪兽送去墓地。给与对方基本分500分的伤害。之后洗切卡组。
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
-- 定义筛选条件：判定一张卡是否为岩石族怪兽，且可作为代价送去墓地，用于从卡组选择送墓对象。
function c20781762.cfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToGraveAsCost()
end
-- 发动代价处理：先确认卡组中存在符合条件的岩石族怪兽，然后选择其中1张送去墓地作为COST，以完成效果发动条件。
function c20781762.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认自己卡组是否存在至少1张满足条件的岩石族怪兽，若存在则代价可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c20781762.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 发送选择提示，提示当前玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己卡组选择1张岩石族且可作为代价送去墓地的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c20781762.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡以COST原因送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的目标设定处理：固定对方玩家为受伤害对象，伤害参数为500，并登记伤害操作信息。
function c20781762.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家，作为之后造成伤害的目标。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，作为之后造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 登记连锁操作信息：向对方玩家造成500点伤害，供相关时点与卡片效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：读取之前设定的目标玩家与伤害参数，对目标玩家给予效果伤害。
function c20781762.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出效果处理所需的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对目标玩家造成伤害，即给予对方500点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
