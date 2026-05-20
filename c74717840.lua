--ランドオルスのヒカリゴケ
-- 效果：
-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。这个回合，对方的效果怪兽不能把效果发动。
function c74717840.initial_effect(c)
	-- 自己场上有名字带有「自然」的怪兽表侧表示存在的场合才能发动。这个回合，对方的效果怪兽不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c74717840.condition)
	e1:SetOperation(c74717840.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且卡名含有「自然」的怪兽
function c74717840.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 发动条件：自己场上存在表侧表示的「自然」怪兽
function c74717840.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「自然」怪兽
	return Duel.IsExistingMatchingCard(c74717840.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果处理：使对方在这个回合不能发动怪兽的效果
function c74717840.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方的效果怪兽不能把效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c74717840.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的类型：怪兽的效果
function c74717840.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
