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
-- 召唤成功时的处理：设置本次连锁结束前的连锁限制，禁止陷阱卡发动。
function c53693416.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 为本次连锁设置限制条件chlimit，直到连锁结束前都生效，用于限制陷阱卡的发动。
	Duel.SetChainLimitTillChainEnd(c53693416.chlimit)
end
-- 判定连锁是否被允许：若该效果不是陷阱卡，或者不是陷阱卡的发动（EFFECT_TYPE_ACTIVATE），则允许发动；即禁止陷阱卡卡的发动。
function c53693416.chlimit(re,rp,tp)
	return not re:GetHandler():IsType(TYPE_TRAP) or not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
