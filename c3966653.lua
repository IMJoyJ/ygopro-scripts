--花札衛－猪鹿蝶－
-- 效果：
-- 调整＋调整以外的怪兽2只
-- ①：只要这张卡在怪兽区域存在，自己的「花札卫」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，把自己墓地1只「花札卫」怪兽除外才能发动。直到下次的对方回合结束时，对方不能把墓地的卡的效果发动，不能从墓地把怪兽特殊召唤。
function c3966653.initial_effect(c)
	-- 添加同调召唤手续，需要1只调整和2只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2,2)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己的「花札卫」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 效果适用对象为自身场上的「花札卫」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe6))
	c:RegisterEffect(e2)
	-- 1回合1次，把自己墓地1只「花札卫」怪兽除外才能发动。直到下次的对方回合结束时，对方不能把墓地的卡的效果发动，不能从墓地把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3966653,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c3966653.cost)
	e3:SetOperation(c3966653.operation)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的墓地「花札卫」怪兽，用于效果发动的代价
function c3966653.spfilter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 检查是否有满足条件的墓地「花札卫」怪兽，若有则选择并除外作为代价
function c3966653.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的墓地「花札卫」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3966653.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张满足条件的墓地「花札卫」怪兽
	local g=Duel.SelectMatchingCard(tp,c3966653.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从墓地除外作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动效果，使对方在接下来的对方回合中不能发动墓地的卡的效果，也不能从墓地特殊召唤怪兽
function c3966653.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使对方不能发动墓地的卡的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c3966653.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 注册效果，使对方在接下来的对方回合中不能发动墓地的卡的效果
	Duel.RegisterEffect(e1,tp)
	-- 使对方不能从墓地特殊召唤怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(0,1)
	e2:SetTarget(c3966653.sumlimit)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 注册效果，使对方在接下来的对方回合中不能从墓地特殊召唤怪兽
	Duel.RegisterEffect(e2,tp)
end
-- 判断效果是否在墓地发动
function c3966653.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
-- 判断是否为从墓地特殊召唤的怪兽
function c3966653.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
