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
-- 在召唤成功时触发：若本回合尚未适用过该效果，则为当前玩家注册一个在通常召唤外追加一次「灵兽」怪兽召唤的效果，并做好标记，处理完毕后结束。
function c14513016.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否已有本回合适用过该效果的标识；若已有，说明效果已适用，直接结束本次处理。
	if Duel.GetFlagEffect(tp,14513016)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「灵兽」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(14513016,0))  --"使用「灵兽使的长老」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设定追加召唤的适用对象：拥有「灵兽」字段（0xb5）的怪兽；即只有此类怪兽可以使用这次追加的通常召唤次数。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb5))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述追加召唤效果以当前玩家tp为对象注册到环境中，使该效果在本回合生效。
	Duel.RegisterEffect(e1,tp)
	-- 为当前玩家tp注册一个回合结束阶段重置的标识效果，用于标记本回合已适用过「灵兽使的长老」的追加召唤效果，防止重复触发。
	Duel.RegisterFlagEffect(tp,14513016,RESET_PHASE+PHASE_END,0,1)
end
