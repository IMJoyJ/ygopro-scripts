--華麗なる潜入工作員
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。
function c89698120.initial_effect(c)
	-- 这张卡召唤成功时，陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c89698120.sumsuc)
	c:RegisterEffect(e1)
end
-- 定义这张卡召唤成功时的效果处理，限制后续连锁中卡片或效果的发动
function c89698120.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置直到当前连锁结束为止的连锁限制条件
	Duel.SetChainLimitTillChainEnd(c89698120.chlimit)
end
-- 定义连锁限制的判定条件，使得双方不能发动陷阱卡的效果
function c89698120.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
