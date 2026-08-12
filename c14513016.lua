--霊獣使いの長老
-- 效果：
-- 自己对「灵兽使的长老」1回合只能有1次特殊召唤。
-- ①：这张卡召唤时适用。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「灵兽」怪兽召唤。
function c14513016.initial_effect(c)
	c:SetSPSummonOnce(14513016)
	-- ①：这张卡召唤时适用。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「灵兽」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c14513016.sumop)
	c:RegisterEffect(e1)
end
-- 效果处理函数，用于响应召唤成功事件
function c14513016.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已使用过该效果，避免重复使用
	if Duel.GetFlagEffect(tp,14513016)~=0 then return end
	-- 创建并注册一个影响场上的效果，使玩家可以在主要阶段额外召唤一次灵兽族怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(14513016,0))  --"使用「灵兽使的长老」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为灵兽族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb5))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，防止该效果在同回合再次使用
	Duel.RegisterFlagEffect(tp,14513016,RESET_PHASE+PHASE_END,0,1)
end
