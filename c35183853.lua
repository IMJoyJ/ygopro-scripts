--鏡鳴する武神
-- 效果：
-- 自己场上有名字带有「武神」的兽战士族怪兽存在，对方场上的怪兽数量比自己场上的怪兽数量多的场合，主要阶段1的开始时才能发动。直到下次的对方回合结束时，双方不能把魔法·陷阱卡的效果发动。
function c35183853.initial_effect(c)
	-- 自己场上有名字带有「武神」的兽战士族怪兽存在，对方场上的怪兽数量比自己场上的怪兽数量多的场合，主要阶段1的开始时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c35183853.condition)
	e1:SetOperation(c35183853.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：卡片必须是表侧表示、属于「武神」系列且为兽战士族，用于检测自己场上是否存在满足发动条件的「武神」兽战士族怪兽。
function c35183853.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 发动条件判定：当前必须为主要阶段1开始时且未进行过任何操作；对方场上的怪兽数量多于自己场上；并且自己场上有1只以上表侧表示的名字带有「武神」的兽战士族怪兽。
function c35183853.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前阶段为主要阶段1，且本阶段尚未有任何操作，以满足「主要阶段1的开始时」这一发动时点条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 比较双方场上怪兽数量：对方场上的怪兽数量比自己场上的怪兽数量多。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 检查自己场上是否存在至少1张符合cfilter条件的「武神」兽战士族表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c35183853.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：创建一个持续效果，禁止双方发动魔法·陷阱卡的效果，并将该效果注册到决斗中，持续到下次对方回合结束。
function c35183853.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的对方回合结束时，双方不能把魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c35183853.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将生成的禁止效果注册进决斗环境，使其对双方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 判定被发动的效果是否为魔法·陷阱卡的效果；若是则禁止发动，用于实现「双方不能把魔法·陷阱卡的效果发动」的限制。
function c35183853.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
