--ガード・ドッグ
-- 效果：
-- 反转：这个回合对方玩家不能特殊召唤。
function c57346400.initial_effect(c)
	-- 反转：这个回合对方玩家不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57346400,0))  --"特召限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c57346400.operation)
	c:RegisterEffect(e1)
end
-- 定义反转效果的处理函数，用于在效果发动后注册限制对方特殊召唤的全局效果。
function c57346400.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方玩家不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的效果注册给全局环境，使其对玩家生效。
	Duel.RegisterEffect(e1,tp)
end
