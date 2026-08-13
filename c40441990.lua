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
-- 筛选可作为发动代价丢弃的手卡：持有「星遗物」字段（0xfe）且可以被丢弃（IsDiscardable）。
function c40441990.costfilter(c)
	return c:IsSetCard(0xfe) and c:IsDiscardable()
end
-- ①效果的代价函数：发动前检查手牌存在满足costfilter的卡；发动时实际从手卡丢弃1张「星遗物」卡作为代价。
function c40441990.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：确认玩家手牌中存在至少1张满足costfilter的「星遗物」卡，否则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40441990.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：让玩家从手卡选择1张「星遗物」卡，以代价+丢弃的原因送去墓地。
	Duel.DiscardHand(tp,c40441990.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果的发动条件判断：玩家可以通常召唤、拥有追加召唤次数，并且本回合尚未发动过该①效果。
function c40441990.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够进行通常召唤，以及是否有追加的通常召唤次数（防止无法发动加召唤的效果）。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否已经用过①效果（通过专用标志40441990是否为0来判断，0表示本回合未曾使用）。
		and Duel.GetFlagEffect(tp,40441990)==0 end
end
-- ①效果处理：给玩家赋予本回合追加1次通常召唤/上级召唤（以及对应的盖放）的能力，并记录本回合已使用的标志。
function c40441990.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 防御性检查：如果本回合标志已存在，说明效果已适用，不再重复处理。
	if Duel.GetFlagEffect(tp,40441990)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。②：这张卡和对方连接怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽回到持有者的额外卡组。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(40441990,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将增加通常召唤次数（EFFECT_EXTRA_SUMMON_COUNT）的永续效果注册给玩家tp，持续到回合结束阶段重置。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 将增加盖放（通常召唤）次数（EFFECT_EXTRA_SET_COUNT）的永续效果注册给玩家tp，持续到回合结束阶段重置。
	Duel.RegisterEffect(e2,tp)
	-- 为玩家tp注册编号40441990的标志效果，记录①效果已在本回合适用过，该标志在结束阶段重置。
	Duel.RegisterFlagEffect(tp,40441990,RESET_PHASE+PHASE_END,0,1)
end
-- ②效果的目标判定：本卡与对方连接怪兽战斗的伤害步骤开始时，若战斗对象是连接怪兽且能返回额外卡组，则满足发动条件。
function c40441990.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return bc and bc:IsType(TYPE_LINK) and bc:IsAbleToExtra() end
	-- 将本次连锁的处理信息设置为“把对象怪兽返回额外卡组”，并指定对象为该战斗对象。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,bc,1,0,0)
end
-- ②效果处理：若战斗对象仍与本次战斗关联（未因其他效果离场等），则将其返回持有者额外卡组。
function c40441990.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 以效果原因将战斗对象送回持有者的额外卡组，并执行洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(bc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
