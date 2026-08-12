--鍵戦士キーマン
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。直到这个回合的结束阶段时，这张卡的等级变成3星。
function c23168060.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。直到这个回合的结束阶段时，这张卡的等级变成3星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23168060,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c23168060.condition)
	e1:SetOperation(c23168060.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否不是3星等级
function c23168060.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLevel(3)
end
-- 将自身等级变为3星直到结束阶段
function c23168060.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到这个回合的结束阶段时，这张卡的等级变成3星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(3)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
