--忍び寄るデビルマンタ
-- 效果：
-- 这张卡召唤成功时，陷阱卡不能发动。
function c52571838.initial_effect(c)
	-- 这张卡召唤成功时，陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c52571838.sumsuc)
	c:RegisterEffect(e1)
end
-- 连锁限制设置为禁止陷阱卡发动
function c52571838.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 设置连锁限制直到连锁结束
	Duel.SetChainLimitTillChainEnd(c52571838.chlimit)
end
-- 判断发动的卡是否为陷阱卡且为发动效果
function c52571838.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
