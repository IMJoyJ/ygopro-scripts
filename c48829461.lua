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
-- 判断c是否在规则上当作所列卡号对应的「罪」怪兽使用，且该卡的效果没有被无效化；用于在「罪 领域」适用时识别场上已有的其他「罪」怪兽。
function c48829461.sfilter(c)
	return c:IsOriginalCodeRule(598988,1710476,9433350,36521459,37115575,55343236) and not c:IsDisabled()
end
-- 定义本卡的场上唯一性判定逻辑：当「罪 领域」效果影响控制者，且场上已存在其他满足sfilter的表侧表示「罪」怪兽时，本卡也必须遵守同类「罪」怪兽每种类只能有1只表侧表示存在的限制；否则不进行额外唯一性限制。
function c48829461.uqfilter(c)
	-- 检查该卡的控制者是否受到「罪 领域」（75223115）的效果影响。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115)
		-- 同时检查该控制者场上是否存在至少1张满足sfilter的怪兽，即另一只规则上当作为所列「罪」怪兽使用且未被无效化的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c48829461.sfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil) then
		return c:IsCode(48829461)
	else
		return false
	end
end
-- ①效果的发动条件：自己的场地区域存在表侧表示的场地魔法卡。
function c48829461.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的场地区域是否存在至少1张表侧表示的卡（即满足有表侧表示的场地魔法卡）。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ①效果的发动代价：需要解放这张卡；chk==0时检查这张卡是否可以被解放，确定可以后执行解放。
function c48829461.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡作为效果发动的代价解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选可以特殊召唤的卡：必须是「罪 平行齿轮」（74509280），能够被特殊召唤，并且其卡组中存在至少1张满足thfilter的「罪」怪兽可供后续检索加入手卡。
function c48829461.spfilter(c,e,tp)
	return c:IsCode(74509280) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认卡组中存在至少1张满足thfilter的卡，且排除作为特召候选的这张「罪 平行齿轮」本身，以保证“那之后”的检索有对象。
		and Duel.IsExistingMatchingCard(c48829461.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 筛选要加入手卡的卡：必须是「罪」字段的怪兽卡，可以加入手卡，且卡名不是「罪 矛盾齿轮」。
function c48829461.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x23) and c:IsAbleToHand() and not c:IsCode(48829461)
end
-- ①效果发动的合法性检查：需要自己场上有可用怪兽区域（考虑解放后空出的格子），且卡组中存在可特殊召唤的「罪 平行齿轮」并同时存在后续可检索的「罪」怪兽。
function c48829461.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区域空格，计算时考虑这张卡被解放后的空位。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时确认卡组中存在满足spfilter的卡（可特召的「罪 平行齿轮」且后续检索有对应对象）。
		and Duel.IsExistingMatchingCard(c48829461.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定操作信息：本次效果包含从卡组特殊召唤怪兽的处理，数量为1，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	-- 设定操作信息：本次效果包含从卡组将卡加入手卡的处理，数量为1，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果处理：先确认仍有怪兽区空格；选择1只「罪 平行齿轮」特殊召唤；然后选择1只「罪 矛盾齿轮」以外的「罪」怪兽加入手卡，并让对方确认；特召与加入手卡之间用BreakEffect隔开，以符合“那之后”的顺序。
function c48829461.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用怪兽区域，若没有则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张满足spfilter的卡（即「罪 平行齿轮」）用于特殊召唤。
	local g1=Duel.SelectMatchingCard(tp,c48829461.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g1:GetCount()>0 then
		-- 将选择的「罪 平行齿轮」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		-- 给玩家显示选择提示，要求选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1张满足thfilter的卡（即「罪 矛盾齿轮」以外的「罪」怪兽）加入手卡。
		local g2=Duel.SelectMatchingCard(tp,c48829461.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 中断当前效果处理，使后续加入手卡的处理与之前的特殊召唤视为不同时处理，避免错误地共享时点。
			Duel.BreakEffect()
			-- 将选择的「罪」怪兽加入其持有者的手卡。
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			-- 让对手确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
