--セイクリッド・ポルクス
-- 效果：
-- ①：这张卡召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星圣」怪兽召唤。
function c78364470.initial_effect(c)
	-- ①：这张卡召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星圣」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c78364470.sumop)
	c:RegisterEffect(e1)
end
-- 召唤成功时，若本回合未适用过该效果，则为玩家注册一个本回合内增加一次「星圣」怪兽通常召唤机会的效果，并注册已适用该效果的标记。
function c78364470.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家本回合是否已适用过该效果，若已适用则不再重复适用。
	if Duel.GetFlagEffect(tp,78364470)~=0 then return end
	-- 自己在通常召唤外加上只有1次，自己主要阶段可以把1只「星圣」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(78364470,0))  --"使用「星圣·北河三」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置追加召唤的目标为「星圣」字段的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x53))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将增加通常召唤次数的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个持续到回合结束的标记，用于记录本回合已适用过该效果。
	Duel.RegisterFlagEffect(tp,78364470,RESET_PHASE+PHASE_END,0,1)
end
