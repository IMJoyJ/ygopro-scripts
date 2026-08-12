--パルキオンのうろこ
-- 效果：
-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。这个回合，对方不能把陷阱卡发动。
function c11813722.initial_effect(c)
	-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c11813722.condition)
	e1:SetOperation(c11813722.operation)
	c:RegisterEffect(e1)
end
-- 检查怪兽是否表侧表示且名字带有「自然」
function c11813722.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 效果发动的条件判断函数
function c11813722.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测我方场上是否存在至少1只满足cfilter条件的怪兽
	return Duel.IsExistingMatchingCard(c11813722.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的处理函数
function c11813722.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能把陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c11813722.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 限制对方不能发动陷阱卡效果的判断函数
function c11813722.aclimit(e,re,tp)
	return re:GetHandler():IsType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
