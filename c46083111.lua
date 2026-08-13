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
-- 定义①效果的检索过滤函数：筛选出卡组中既是怪兽又能被送去墓地的卡片，供「从卡组把1只怪兽送去墓地」使用。
function c46083111.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 定义①效果的发动条件与操作信息：在发动确认时检查卡组是否存在符合条件的怪兽，并设置将要送去墓地的1张卡的信息。
function c46083111.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中不存在满足tgfilter条件的怪兽时，①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46083111.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将把1张卡从卡组送去墓地（配合连锁判定，如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果的处理函数：实际从卡组选1只怪兽送去墓地。
function c46083111.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方卡组选择1张满足tgfilter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c46083111.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义②效果的发动条件：这张卡在被对方效果导致离场前，必须是表侧表示且由我方控制。
function c46083111.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 定义②效果的可特殊召唤卡筛选函数：筛选出卡组中属于「机怪虫」字段、不是「机怪虫·树突虫」自身、且可以里侧守备表示特殊召唤的怪兽。
function c46083111.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(46083111) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 定义②效果的发动条件与目标选择：在发动确认时检查无青眼精灵龙限制、己方主要怪兽区有空位、且卡组中存在至少2种卡名不同的符合条件的「机怪虫」怪兽，并设置特殊召唤2只的操作信息。
function c46083111.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 发动条件检查：己方主要怪兽区可用空格少于2个时，②效果不能发动。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 在发动确认时获取卡组中所有符合条件的「机怪虫」怪兽，用于判断是否存在至少2种不同卡名。
		local g=Duel.GetMatchingGroup(c46083111.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置操作信息：本次效果处理将把2只怪兽从卡组特殊召唤（实际以里侧守备表示特殊召唤，附带盖放性质）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 定义②效果的处理函数：效果处理时再次确认限制，从卡组选择2只卡名不同且符合条件的「机怪虫」怪兽，以里侧守备表示特殊召唤，并让对方确认。
function c46083111.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查：己方主要怪兽区可用空格少于2个，则本次特殊召唤不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 效果处理时获取卡组中所有符合条件的「机怪虫」怪兽，用于实际选择要特殊召唤的卡片。
	local g=Duel.GetMatchingGroup(c46083111.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的「机怪虫」怪兽组中，让玩家选出2张卡名互不相同的卡片（同名卡最多1张）。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选出的2只怪兽以里侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 将里侧守备特殊召唤的卡展示给对方玩家确认（因为里侧表示怪兽通常不可见，需要确认其卡名）。
		Duel.ConfirmCards(1-tp,sg)
	end
end
