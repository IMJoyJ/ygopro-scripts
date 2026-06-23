--侵略の炎
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。
function c26082229.initial_effect(c)
	-- 这张卡召唤成功时，陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c26082229.sumsuc)
	c:RegisterEffect(e1)
end
-- 设置连锁限制，阻止陷阱卡发动
function c26082229.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制函数，使陷阱卡无法发动
	Duel.SetChainLimitTillChainEnd(c26082229.chlimit)
end
-- 连锁限制函数，判断是否为陷阱卡的发动效果
function c26082229.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
