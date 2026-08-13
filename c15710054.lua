--クローラー・アクソン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·轴突虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c15710054.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡反转的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15710054,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,15710054)
	e1:SetTarget(c15710054.target)
	e1:SetOperation(c15710054.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·轴突虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15710054,1))  --"2只怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,15710055)
	e2:SetCondition(c15710054.spcon)
	e2:SetTarget(c15710054.sptg)
	e2:SetOperation(c15710054.spop)
	c:RegisterEffect(e2)
end
-- ①效果发动时的对象选择与操作信息设置：确认场上存在可选取的魔法·陷阱卡，提示玩家选择1张，将其设为效果对象，并登记破坏该卡的操作信息。
function c15710054.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 效果发动合法性检查：确认场上是否存在至少1张魔法·陷阱卡能够成为效果对象；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 向操作玩家显示“请选择要破坏的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家tp从双方场上选择1张魔法·陷阱卡作为效果对象，并将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置破坏类操作信息：本次连锁将破坏选中的那1张卡，供其他效果（如星尘龙等）判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象卡，若该卡仍与效果关联（未离场或被无效化），则将其以效果原因破坏。
function c15710054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动效果时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡在离场前为表侧表示且由自己控制，离场原因是对方的效果，且该效果的控制者是对方；满足时允许发动。
function c15710054.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 定义可特殊召唤的卡组怪兽条件：属于「机怪虫」系列（0x104）、不是「机怪虫·轴突虫」自身、且能够以里侧守备表示特殊召唤。
function c15710054.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(15710054) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果发动时判定：确认没有青眼精灵龙的“不能同时特殊召唤2只以上怪兽”限制；自己主要怪兽区有至少2个空格；卡组中存在至少2张卡名不同的符合条件的「机怪虫」怪兽。满足后设置从卡组特殊召唤2只怪兽的操作信息。
function c15710054.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查自己场上的主要怪兽区可用空格数是否不少于2；不足则不能发动。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 从自己卡组筛选出所有满足filter1条件的「机怪虫」怪兽作为候选集合。
		local g=Duel.GetMatchingGroup(c15710054.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置特殊召唤操作信息：预计从卡组特殊召唤2只怪兽（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理：再次确认青眼精灵龙限制和怪兽区空格；从卡组选择2张卡名不同的符合条件的「机怪虫」怪兽，以里侧守备表示特殊召唤，并向对方展示确认。
function c15710054.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次检查自己场上有至少2个可用怪兽区；若不满足则本效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 处理阶段重新从卡组筛选符合条件的「机怪虫」怪兽作为可选特殊召唤对象。
	local g=Duel.GetMatchingGroup(c15710054.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 显示“请选择要特殊召唤的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选择2张卡名互不相同的「机怪虫」怪兽（同名卡最多1张）作为特殊召唤对象。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的2张怪兽以里侧守备表示特殊召唤到自己的怪兽区（不跳过召唤条件与苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家展示这2张特殊召唤的怪兽卡，使其确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
