--スペア・ジェネクス
-- 效果：
-- ①：1回合1次，自己场上有其他的「次世代」怪兽存在的场合才能发动。这张卡的卡名直到结束阶段当作「次世代控制员」使用。
function c16828633.initial_effect(c)
	-- ①：1回合1次，自己场上有其他的「次世代」怪兽存在的场合才能发动。这张卡的卡名直到结束阶段当作「次世代控制员」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16828633,0))  --"当作「次世代控制员」使用"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c16828633.condition)
	e1:SetOperation(c16828633.operation)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「次世代」怪兽
function c16828633.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2)
end
-- 效果发动时的条件判断，检查自己场上是否存在其他「次世代」怪兽
function c16828633.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为玩家，在自己的主要怪兽区是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c16828633.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 将自身卡名变更为「次世代控制员」直到结束阶段
function c16828633.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的卡名直到结束阶段当作「次世代控制员」使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(68505803)
	c:RegisterEffect(e1)
end
