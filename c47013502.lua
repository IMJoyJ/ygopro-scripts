--アボイド・ドラゴン
-- 效果：
-- 这张卡的召唤不会被无效化。这张卡召唤成功的回合，对方不能把反击陷阱卡发动。
function c47013502.initial_effect(c)
	-- 这张卡的召唤不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 这张卡召唤成功的回合，对方不能把反击陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c47013502.sumsuc)
	c:RegisterEffect(e2)
end
-- 这张卡召唤成功时触发，创建一个影响全场的永续效果，使对方玩家在本回合内不能发动反击陷阱卡，该效果在结束阶段重置。
function c47013502.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡召唤成功的回合，对方不能把反击陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c47013502.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述“对方不能发动反击陷阱卡”的限制效果e1注册到当前玩家tp的场上，使其对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 作为限制效果的判定函数，检查对手发动的效果所在卡是否属于反击陷阱，若是则禁止发动。
function c47013502.actlimit(e,te,tp)
	return te:GetHandler():IsType(TYPE_COUNTER)
end
