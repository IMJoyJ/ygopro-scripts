--鏡鳴する武神
-- 效果：
-- 自己场上有名字带有「武神」的兽战士族怪兽存在，对方场上的怪兽数量比自己场上的怪兽数量多的场合，主要阶段1的开始时才能发动。直到下次的对方回合结束时，双方不能把魔法·陷阱卡的效果发动。
function c35183853.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点的自由连锁效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c35183853.condition)
	e1:SetOperation(c35183853.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检查场上是否存在表侧表示的兽战士族「武神」怪兽
function c35183853.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 效果发动条件判断，包括当前阶段为主要阶段1、未进行阶段操作、对方怪兽数量多于己方、己方场上存在符合条件的怪兽
function c35183853.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1且未进行阶段操作
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
		-- 比较对方怪兽数量是否多于己方怪兽数量
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		-- 检查己方场上是否存在至少1只符合条件的「武神」兽战士族怪兽
		and Duel.IsExistingMatchingCard(c35183853.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时，创建并注册一个持续到下次对方回合结束的禁止双方发动魔法·陷阱卡效果的永续效果
function c35183853.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 创建禁止发动效果，设置影响对象为双方玩家，禁止发动魔法与陷阱卡的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c35183853.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果注册给当前玩家，使效果生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的函数，用于判断是否为魔法或陷阱卡的效果
function c35183853.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
