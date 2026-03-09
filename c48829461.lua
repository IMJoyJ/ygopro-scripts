--Sin パラドクスギア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场地魔法卡表侧表示存在的场合，把这张卡解放才能发动。从卡组把1只「罪 平行齿轮」特殊召唤。那之后，从卡组把「罪 矛盾齿轮」以外的1只「罪」怪兽加入手卡。
-- ②：为让自己手卡的「罪」怪兽用自身的方法特殊召唤而把怪兽除外的场合，可以作为那怪兽的代替而把场上·墓地的这张卡除外。
function c48829461.initial_effect(c)
	c:SetUniqueOnField(1,1,c48829461.uqfilter,LOCATION_MZONE)
	-- ①：场地魔法卡表侧表示存在的场合，把这张卡解放才能发动。从卡组把1只「罪 平行齿轮」特殊召唤。那之后，从卡组把「罪 矛盾齿轮」以外的1只「罪」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,48829461)
	e1:SetCondition(c48829461.condition)
	e1:SetCost(c48829461.cost)
	e1:SetTarget(c48829461.target)
	e1:SetOperation(c48829461.operation)
	c:RegisterEffect(e1)
	-- ②：为让自己手卡的「罪」怪兽用自身的方法特殊召唤而把怪兽除外的场合，可以作为那怪兽的代替而把场上·墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(48829461)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,48829462)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为「罪」怪兽（包括平行齿轮等）且未被无效化。
function c48829461.sfilter(c)
	return c:IsOriginalCodeRule(598988,1710476,9433350,36521459,37115575,55343236) and not c:IsDisabled()
end
-- 唯一性过滤函数，当玩家受到效果影响且场上存在符合条件的「罪」怪兽时，该卡在场上只能存在一张。
function c48829461.uqfilter(c)
	-- 检查当前玩家是否受到某个效果影响（如「罪」怪兽效果限制）。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115)
		-- 检查当前玩家场上是否存在至少1张符合条件的「罪」怪兽。
		and Duel.IsExistingMatchingCard(c48829461.sfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		return c:IsCode(48829461)
	else
		return false
	end
end
-- 判断发动条件：场地魔法卡表侧表示存在于场上的场合。
function c48829461.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以当前玩家来看，场地区是否存在至少1张表侧表示的场地魔法卡。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置发动代价：解放自身。
function c48829461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从场上解放作为发动代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤函数，用于筛选「罪 平行齿轮」并确保其可以被特殊召唤且后续能检索其他「罪」怪兽。
function c48829461.spfilter(c,e,tp)
	return c:IsCode(74509280) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否在卡组中存在满足条件的「罪」怪兽以加入手牌。
		and Duel.IsExistingMatchingCard(c48829461.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 检索过滤函数，用于筛选「罪」怪兽（除自身外）并确保其可以加入手牌。
function c48829461.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x23) and c:IsAbleToHand() and not c:IsCode(48829461)
end
-- 设置发动时的目标信息：准备特殊召唤和加入手牌的卡。
function c48829461.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件：场上存在空怪兽区。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查是否在卡组中存在满足条件的「罪 平行齿轮」以进行特殊召唤。
		and Duel.IsExistingMatchingCard(c48829461.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	-- 设置操作信息：准备将一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 执行效果处理：先检索并特殊召唤「罪 平行齿轮」，再检索其他「罪」怪兽加入手牌。
function c48829461.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家场上是否还有可用的怪兽区。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的「罪 平行齿轮」进行特殊召唤。
	local g1=Duel.SelectMatchingCard(tp,c48829461.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		-- 将选中的卡以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择满足条件的「罪」怪兽加入手牌。
		local g2=Duel.SelectMatchingCard(tp,c48829461.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 中断当前效果处理，使后续操作视为错时点。
			Duel.BreakEffect()
			-- 将选中的卡以效果原因送入玩家手牌。
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			-- 向对方确认所选卡的卡面内容。
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
