--EMディスカバー・ヒッポ
-- 效果：
-- ①：这张卡召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
function c41440148.initial_effect(c)
	-- ①：这张卡召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c41440148.sumop)
	c:RegisterEffect(e1)
end
-- 召唤成功时触发，若本回合尚未使用过该效果，则给当前玩家赋予一次额外通常召唤的机会（仅限手牌7星以上怪兽），并记录已使用标记；否则不处理。
function c41440148.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否已有编号41440148的标志效果（即本回合是否已发动过此效果），若已发动则直接终止处理，确保每回合只使用一次。
	if Duel.GetFlagEffect(tp,41440148)~=0 then return end
	-- 自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(41440148,0))  --"使用「娱乐伙伴 探寻河马」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外通常召唤效果的适用对象：只有等级在7星以上的怪兽才能享受这次额外召唤（配合上级召唤使用）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,7))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该额外召唤次数效果注册给当前玩家tp，使其从此刻起在本回合内生效，玩家可额外进行一次满足条件的上级召唤。
	Duel.RegisterEffect(e1,tp)
	-- 为当前玩家tp注册一个回合结束阶段重置的标志效果，记录本回合已使用过该效果；若再次触发召唤成功时，会因该标志而不再重复赋予额外召唤次数。
	Duel.RegisterFlagEffect(tp,41440148,RESET_PHASE+PHASE_END,0,1)
end
