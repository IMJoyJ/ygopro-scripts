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
-- 定义「次世代」怪兽的筛选条件：表侧表示且属于「次世代」系列（SetCard 0x2）。
function c16828633.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2)
end
-- 效果的发动条件：检查自己场上是否存在其他表侧表示的「次世代」怪兽（排除本卡），满足时效果才能发动。
function c16828633.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 调用 Duel.IsExistingMatchingCard 检测自己怪兽区是否存在至少1张满足 cfilter 条件且不为效果持有者的「次世代」怪兽。
	return Duel.IsExistingMatchingCard(c16828633.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果处理：确认本卡仍与效果关联且不是里侧表示后，为本卡注册改变卡名的效果，使其直到结束阶段卡名当作「次世代控制员」。
function c16828633.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的卡名直到结束阶段当作「次世代控制员」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(68505803)
	c:RegisterEffect(e1)
end
