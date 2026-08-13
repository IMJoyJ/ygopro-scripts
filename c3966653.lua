--花札衛－猪鹿蝶－
-- 效果：
-- 调整＋调整以外的怪兽2只
-- ①：只要这张卡在怪兽区域存在，自己的「花札卫」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：1回合1次，把自己墓地1只「花札卫」怪兽除外才能发动。直到下次的对方回合结束时，对方不能把墓地的卡的效果发动，不能从墓地把怪兽特殊召唤。
function c3966653.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽＋2只调整以外的怪兽（调整部分不做额外限制，非调整用aux.NonTuner(nil)表示任意调整以外的怪兽，非调整数量固定为2）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己的「花札卫」怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 将贯穿效果的作用对象限定为我方场上表侧表示的「花札卫」字段怪兽（0xe6），即只有这些怪兽攻击守备表示怪兽时才能造成贯穿伤害。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xe6))
	c:RegisterEffect(e2)
	-- ②：1回合1次，把自己墓地1只「花札卫」怪兽除外才能发动。直到下次的对方回合结束时，对方不能把墓地的卡的效果发动，不能从墓地把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3966653,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c3966653.cost)
	e3:SetOperation(c3966653.operation)
	c:RegisterEffect(e3)
end
-- 定义可以除外作为代价的「花札卫」怪兽筛选条件：必须是「花札卫」字段的怪兽卡，并且能够作为代价被除外。
function c3966653.spfilter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理：先检查墓地是否存在满足条件的「花札卫」怪兽，再从自己的墓地选择1只「花札卫」怪兽，以表侧表示除外作为发动代价。
function c3966653.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认自己墓地是否存在至少1只满足spfilter条件的「花札卫」怪兽，若存在才能发动该效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c3966653.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示选择卡片的提示信息，提示内容为“请选择要除外的卡”，用于告知玩家正在选择发动代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地的满足spfilter条件的卡中选择1张「花札卫」怪兽，作为发动代价要除外的对象。
	local g=Duel.SelectMatchingCard(tp,c3966653.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「花札卫」怪兽以表侧表示从墓地除外，reason为REASON_COST，即作为发动该效果的代价除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果处理：创建并注册两个持续影响对方的禁止效果——（1）禁止对方从墓地发动卡的效果；（2）禁止对方从墓地特殊召唤怪兽；两者都持续到下次对方回合结束。
function c3966653.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 直到下次的对方回合结束时，对方不能把墓地的卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c3966653.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将e1注册到以tp为掌控者的场上，使其对对方玩家生效：对方不能发动由墓地发动的卡的效果，持续到重置时点。
	Duel.RegisterEffect(e1,tp)
	-- 不能从墓地把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(0,1)
	e2:SetTarget(c3966653.sumlimit)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将e2注册到以tp为掌控者的场上，使其对对方玩家生效：对方不能从墓地特殊召唤怪兽，持续到重置时点。
	Duel.RegisterEffect(e2,tp)
end
-- 判断对方正要发动的效果是否为墓地发动的效果：如果效果发动位置（re:GetActivateLocation()）是墓地，则禁止其发动。
function c3966653.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
-- 判断对方正要特殊召唤的怪兽是否来自墓地且为怪兽卡：如果怪兽位于墓地且是怪兽类型，则禁止该特殊召唤。
function c3966653.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
