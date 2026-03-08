--幻奏の音女セレナ
-- 效果：
-- ①：天使族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ②：这张卡特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
function c42029847.initial_effect(c)
	-- 效果原文内容：天使族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c42029847.condition)
	c:RegisterEffect(e1)
	-- 效果原文内容：这张卡特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c42029847.regop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否为天使族怪兽。
function c42029847.condition(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 规则层面作用：注册特殊召唤成功后的效果，用于在主要阶段额外召唤一次幻奏怪兽。
function c42029847.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查是否已使用过该效果，避免重复触发。
	if Duel.GetFlagEffect(tp,42029847)~=0 then return end
	-- 效果原文内容：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(42029847,0))  --"使用「幻奏的音女 塞瑞娜」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 规则层面作用：设置效果目标为「幻奏」卡组的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：将效果注册到场上。
	Duel.RegisterEffect(e1,tp)
	-- 规则层面作用：为玩家注册一个标识效果，防止该效果在同回合重复使用。
	Duel.RegisterFlagEffect(tp,42029847,RESET_PHASE+PHASE_END,0,1)
end
