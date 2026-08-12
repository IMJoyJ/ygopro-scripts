--真空イタチ
-- 效果：
-- ①：这张卡反转的场合发动。这个回合，对方不能把魔法·陷阱卡发动。
function c93730409.initial_effect(c)
	-- ①：这张卡反转的场合发动。这个回合，对方不能把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93730409,0))  --"发动限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c93730409.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：创建一个限制对方玩家发动的效果，并注册给全局环境。
function c93730409.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c93730409.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该限制效果注册给全局环境，使其对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限定不能发动的类型为魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE）。
function c93730409.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
