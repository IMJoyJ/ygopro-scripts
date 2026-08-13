--パルキオンのうろこ
-- 效果：
-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。这个回合，对方不能把陷阱卡发动。
function c11813722.initial_effect(c)
	-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。这个回合，对方不能把陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c11813722.condition)
	e1:SetOperation(c11813722.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：卡片须为表侧表示且卡名含有「自然」字段。
function c11813722.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 发动条件判定：己方场上是否存在1只以上的表侧表示「自然」怪兽。
function c11813722.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否存在至少1只满足cfilter过滤条件的怪兽。
	return Duel.IsExistingMatchingCard(c11813722.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：生成一个永续效果，本回合内禁止对方玩家发动陷阱卡。
function c11813722.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能把陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c11813722.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该封禁陷阱卡的效果注册到场上，其持有者为发动者tp。
	Duel.RegisterEffect(e1,tp)
end
-- 追加判定：对方发动的效果必须为陷阱卡的“发动”（卡片种类为陷阱且效果类型为效果发动）。
function c11813722.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
