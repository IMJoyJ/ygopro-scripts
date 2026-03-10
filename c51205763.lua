--クローラー・グリア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合才能发动。从自己的手卡·墓地选「机怪虫·神经胶质虫」以外的1只「机怪虫」怪兽表侧攻击表示或者里侧守备表示特殊召唤。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·神经胶质虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c51205763.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从自己的手卡·墓地选「机怪虫·神经胶质虫」以外的1只「机怪虫」怪兽表侧攻击表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51205763,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,51205763)
	e1:SetTarget(c51205763.target)
	e1:SetOperation(c51205763.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·神经胶质虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51205763,1))  --"2只怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,51205764)
	e2:SetCondition(c51205763.spcon)
	e2:SetTarget(c51205763.sptg)
	e2:SetOperation(c51205763.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「机怪虫」怪兽，排除自身且可特殊召唤。
function c51205763.filter(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(51205763) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 判断是否满足①效果的发动条件：场上是否有空位且手牌或墓地是否存在符合条件的怪兽。
function c51205763.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有至少一个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌或墓地是否存在至少一张符合条件的「机怪虫」怪兽。
		and Duel.IsExistingMatchingCard(c51205763.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤1张符合条件的卡到手牌或墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的处理函数：若场上存在空位，则提示选择并特殊召唤符合条件的怪兽。
function c51205763.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有至少一个空位，若无则返回不执行效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地选择一张符合条件的「机怪虫」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51205763.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽以指定形式特殊召唤到场上，并确认对方可见。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
		-- 若特殊召唤成功且该怪兽为里侧表示，则向对方确认其卡面内容。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果的发动条件函数：判断此卡是否因对方效果从场上离开且处于表侧表示状态。
function c51205763.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 过滤函数，用于筛选满足条件的「机怪虫」怪兽，排除自身且可特殊召唤（仅里侧守备）。
function c51205763.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(51205763) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果的目标设定函数：判断是否满足发动条件并设置操作信息。
function c51205763.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查玩家场上是否有至少两个空位，若不足则返回不执行效果。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 获取卡组中所有符合条件的「机怪虫」怪兽。
		local g=Duel.GetMatchingGroup(c51205763.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置连锁操作信息，表示将特殊召唤2张符合条件的卡到卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果的处理函数：若满足条件则提示选择并特殊召唤2只符合条件的怪兽。
function c51205763.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有至少两个空位，若不足则返回不执行效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有符合条件的「机怪虫」怪兽。
	local g=Duel.GetMatchingGroup(c51205763.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 向玩家发送提示信息，提示其选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择2张不同卡名的怪兽。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的2只怪兽以里侧守备形式特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 若特殊召唤成功，则向对方确认其卡面内容。
		Duel.ConfirmCards(1-tp,sg)
	end
end
