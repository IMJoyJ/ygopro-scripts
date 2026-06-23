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
-- 当此卡召唤成功时执行的处理函数
function c41440148.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已在该回合使用过此效果
	if Duel.GetFlagEffect(tp,41440148)~=0 then return end
	-- 创建一个影响场上的效果，使玩家可以在主要阶段将手牌中7星以上的怪兽进行上级召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(41440148,0))  --"使用「娱乐伙伴 探寻河马」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为等级7以上的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,7))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个标识效果，防止此效果在该回合重复使用
	Duel.RegisterFlagEffect(tp,41440148,RESET_PHASE+PHASE_END,0,1)
end
