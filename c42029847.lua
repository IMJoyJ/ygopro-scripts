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
-- 判断上级召唤的怪兽是否为天使族怪兽
function c42029847.condition(e,c)
	local ec=e:GetHandler()
	return c:IsRace(RACE_FAIRY) and (ec:IsFaceup() or c:GetControler()==ec:GetControler())
end
-- 特殊召唤成功时，注册增加1次「幻奏」怪兽通常召唤机会的效果
function c42029847.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否已注册过增加召唤次数的效果
	if Duel.GetFlagEffect(tp,42029847)~=0 then return end
	-- 自己在通常召唤外加上只有1次，自己主要阶段可以把1只「幻奏」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(42029847,0))  --"使用「幻奏的音女 塞瑞娜」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤适用的怪兽范围为「幻奏」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册增加通常召唤次数的效果
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册标记，限制该效果本回合只能适用1次
	Duel.RegisterFlagEffect(tp,42029847,RESET_PHASE+PHASE_END,0,1)
end
