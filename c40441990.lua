--星遺物－『星鍵』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1张「星遗物」卡才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
-- ②：这张卡和对方连接怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽回到持有者的额外卡组。
function c40441990.initial_effect(c)
	-- ①：从手卡丢弃1张「星遗物」卡才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40441990,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40441990)
	e1:SetCost(c40441990.sumcost)
	e1:SetTarget(c40441990.sumtg)
	e1:SetOperation(c40441990.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方连接怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽回到持有者的额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40441990,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,40441991)
	e2:SetTarget(c40441990.tetg)
	e2:SetOperation(c40441990.teop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在1张「星遗物」卡且可丢弃
function c40441990.costfilter(c)
	return c:IsSetCard(0xfe) and c:IsDiscardable()
end
-- 检查玩家是否可以丢弃1张「星遗物」卡作为发动代价
function c40441990.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以丢弃1张「星遗物」卡作为发动代价
	if chk==0 then return Duel.IsExistingMatchingCard(c40441990.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家丢弃1张「星遗物」卡作为发动代价
	Duel.DiscardHand(tp,c40441990.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查玩家是否可以通常召唤且是否有额外召唤次数且本回合未发动过①效果
function c40441990.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以通常召唤且是否有额外召唤次数
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否已发动过①效果
		and Duel.GetFlagEffect(tp,40441990)==0 end
end
-- 效果发动时，为玩家注册额外召唤次数和盖放次数效果，并注册标识效果防止重复发动
function c40441990.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否已发动过①效果
	if Duel.GetFlagEffect(tp,40441990)~=0 then return end
	-- 为玩家注册额外召唤次数效果，使玩家在主要阶段可以上级召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(40441990,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外召唤次数效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 将盖放次数效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 注册标识效果，防止本回合再次发动①效果
	Duel.RegisterFlagEffect(tp,40441990,RESET_PHASE+PHASE_END,0,1)
end
-- 设置连锁操作信息，确定效果处理时将对方连接怪兽送回额外卡组
function c40441990.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsType(TYPE_LINK) and bc:IsAbleToExtra() end
	-- 设置连锁操作信息，确定效果处理时将对方连接怪兽送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,bc,1,0,0)
end
-- 效果发动时，将对方连接怪兽送回其额外卡组
function c40441990.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将对方连接怪兽送回其额外卡组
		Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
