--テーヴァ
-- 效果：
-- ①：这张卡上级召唤成功的场合发动。下次的对方回合，对方不能攻击宣言。
function c16469012.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合发动。下次的对方回合，对方不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16469012,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c16469012.condition)
	e1:SetOperation(c16469012.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：只有当这张卡是以“上级召唤”方式成功召唤时，本效果才满足发动条件。
function c16469012.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果处理操作：创建并注册一个影响全场的永续效果，设置该效果为“不能进行攻击宣言”，且仅影响对方主要怪兽区域的怪兽，并在经过2次结束阶段后自动重置（即在下个对方回合内禁止对方攻击宣言）。
function c16469012.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合，对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将上面生成的“对方怪兽不能攻击宣言”的限制效果注册到场上，使其开始实际适用。
	Duel.RegisterEffect(e1,tp)
end
