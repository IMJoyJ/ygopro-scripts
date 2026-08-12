--クローラー・デンドライト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从卡组把1只怪兽送去墓地。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·树突虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c46083111.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46083111,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,46083111)
	e1:SetTarget(c46083111.tgtg)
	e1:SetOperation(c46083111.tgop)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·树突虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46083111,1))  --"2只怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,46083112)
	e2:SetCondition(c46083111.spcon)
	e2:SetTarget(c46083111.sptg)
	e2:SetOperation(c46083111.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选可以送去墓地的怪兽
function c46083111.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果处理时需要确认是否满足条件，检查场上是否存在至少1张可送去墓地的怪兽
function c46083111.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46083111.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为送去墓地效果，目标为卡组中1张怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动后的实际操作，选择并把怪兽送去墓地
function c46083111.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c46083111.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤条件，即该卡是因对方效果离场且处于正面表示状态
function c46083111.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 过滤函数，筛选可以特殊召唤的「机怪虫」怪兽（不包括自身）
function c46083111.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(46083111) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置效果处理时需要确认是否满足条件，检查是否有足够的召唤位置并确保能选出2张不同卡名的怪兽
function c46083111.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查玩家场上是否有至少2个空位用于特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 获取所有满足条件的「机怪虫」怪兽组
		local g=Duel.GetMatchingGroup(c46083111.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息为特殊召唤效果，目标为卡组中2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 处理效果发动后的实际操作，选择并把2只怪兽特殊召唤
function c46083111.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有至少2个空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取所有满足条件的「机怪虫」怪兽组
	local g=Duel.GetMatchingGroup(c46083111.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选出2张不同卡名的怪兽组
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的怪兽以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
