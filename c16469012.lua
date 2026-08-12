--テーヴァ
-- 效果：
-- ①：这张卡上级召唤成功的场合发动。下次的对方回合，对方不能攻击宣言。
function c16469012.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16469012,0))  --"攻击限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c16469012.condition)
	e1:SetOperation(c16469012.operation)
	c:RegisterEffect(e1)
end
-- 检查本次召唤是否为上级召唤
function c16469012.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 创建对方怪兽区域怪兽不能攻击的效果
function c16469012.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合，对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
