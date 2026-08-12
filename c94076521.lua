--水界の秘石－カトリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只地·水属性怪兽召唤。
-- ②：这张卡在墓地存在，自己场上有地属性怪兽以及水属性怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c94076521.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只地·水属性怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94076521,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,94076521)
	e1:SetCost(c94076521.sumcost)
	e1:SetTarget(c94076521.sumtg)
	e1:SetOperation(c94076521.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有地属性怪兽以及水属性怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(94076521,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,94076522)
	e2:SetCondition(c94076521.spcon)
	e2:SetTarget(c94076521.sptg)
	e2:SetOperation(c94076521.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价：将手牌的这张卡丢弃。
function c94076521.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价将这张卡丢弃送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动检测：检查玩家是否能通常召唤、是否还有额外的召唤次数，以及本回合是否尚未适用过该效果。
function c94076521.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以进行通常召唤、是否可以增加召唤次数，且本回合未注册过该效果的标识。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) and Duel.GetFlagEffect(tp,94076521)==0 end
end
-- 效果①的效果处理：为玩家注册一个本回合内可以额外召唤1只地·水属性怪兽的效果，并注册已适用的标识。
function c94076521.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合已适用过该效果，则不处理。
	if Duel.GetFlagEffect(tp,94076521)~=0 then return end
	local c=e:GetHandler()
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只地·水属性怪兽召唤。②：这张卡在墓地存在，自己场上有地属性怪兽以及水属性怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94076521,2))  --"使用「水界之秘石-短吻龙」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤效果的目标为地属性或水属性怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH+ATTRIBUTE_WATER))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该额外召唤效果。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个回合结束时重置的标识，用于防止同回合重复适用该效果。
	Duel.RegisterFlagEffect(tp,94076521,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：场上表侧表示的指定属性的怪兽。
function c94076521.cfilter(c,attr)
	return c:IsFaceup() and c:IsAttribute(attr)
end
-- 效果②的发动条件：检查自己场上是否存在地属性怪兽以及水属性怪兽。
function c94076521.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的地属性怪兽。
	return Duel.IsExistingMatchingCard(c94076521.cfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_EARTH)
		-- 检查自己场上是否存在表侧表示的水属性怪兽。
		and Duel.IsExistingMatchingCard(c94076521.cfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_WATER)
end
-- 效果②的发动检测与操作信息设置：检查怪兽区域是否有空位，以及这张卡是否能特殊召唤，并设置特殊召唤的操作信息。
function c94076521.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：将1张卡（这张卡）特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将这张卡特殊召唤，并注册“离场时除外”的效果。
function c94076521.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于墓地，则将其在自己场上表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
