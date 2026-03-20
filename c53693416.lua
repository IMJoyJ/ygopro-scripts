--イーグル・アイ
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。
function c53693416.initial_effect(c)
	-- 这张卡召唤成功时，陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c53693416.sumsuc)
	c:RegisterEffect(e1)
end
-- 召唤成功时触发，设置连锁限制直到连锁结束
function c53693416.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制直到连锁结束，阻止陷阱卡发动
	Duel.SetChainLimitTillChainEnd(c53693416.chlimit)
end
-- 判断发动的卡片是否为陷阱卡，若是则阻止发动
function c53693416.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
