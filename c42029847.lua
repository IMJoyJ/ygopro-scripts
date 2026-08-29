--幻奏の音女セレナ
-- 效果：
-- ①：天使族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
-- ②：这张卡特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
function c42029847.initial_effect(c)
	-- ①：天使族怪兽上级召唤的场合，这张卡可以作为2只的数量解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(c42029847.condition)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c42029847.regop)
	c:RegisterEffect(e2)
end
-- 判定被上级召唤的怪兽是否为天使族，若是则这张卡可作为2只解放素材使用。
function c42029847.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_FAIRY) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 特殊召唤成功时，若本回合尚未使用过该效果，则为玩家注册一个持续到结束阶段的额外召唤次数效果，并设置对应的触发标记。
function c42029847.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否已拥有本回合使用过该效果的标记，若已有则直接返回，避免重复赋予额外召唤次数。
	if Duel.GetFlagEffect(tp,42029847)~=0 then return end
	-- 自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(42029847,0))  --"使用「幻奏的音女 塞瑞娜」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤次数效果的适用对象：只有卡名属于「幻奏」系列的怪兽才能享受这次额外通常召唤。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该额外召唤次数效果作为玩家效果注册，使其在本回合内对适用的「幻奏」怪兽生效。
	Duel.RegisterEffect(e1,tp)
	-- 给当前玩家设置一个本回合已发动过该效果的标记，重置时机为结束阶段，用于防止同回合重复触发。
	Duel.RegisterFlagEffect(tp,42029847,RESET_PHASE+PHASE_END,0,1)
end
