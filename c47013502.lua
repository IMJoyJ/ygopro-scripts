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
-- 在怪兽通常召唤成功时，将一个永续效果注册给对方玩家，使对方不能发动反击陷阱卡。
function c47013502.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方玩家不能发动类型为反击的陷阱卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c47013502.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp。
	Duel.RegisterEffect(e1,tp)
end
-- 判断被发动的效果是否为反击类型的陷阱卡。
function c47013502.actlimit(e,te,tp)
	return te:GetHandler():IsType(TYPE_COUNTER)
end
