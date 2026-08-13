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
-- 定义①效果可特殊召唤的怪兽的筛选条件：必须是「机怪虫」系列、不是「机怪虫·神经胶质虫」自身、且可以以表侧攻击或里侧守备表示特殊召唤。
function c51205763.filter(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(51205763) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- ①效果的发动条件判定：自己主要怪兽区有空位，且手牌·墓地存在满足筛选条件的「机怪虫」怪兽。
function c51205763.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认自己场上是否有可用的怪兽区域，若无空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手牌·墓地是否存在至少1只满足条件的「机怪虫」怪兽（非本卡名）。
		and Duel.IsExistingMatchingCard(c51205763.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时将要进行特殊召唤的操作信息，数量为1，来源为手牌·墓地，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理时，若场上已无空位则直接终止；否则提示玩家选择1只手牌·墓地的「机怪虫」怪兽，以表侧攻击或里侧守备表示特殊召唤，若里侧表示特殊召唤则向对方确认。
function c51205763.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认主要怪兽区仍有空位，若已无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示框，供玩家从符合条件的卡中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手牌·墓地选出1只满足条件且不受「王家长眠之谷」影响的「机怪虫」怪兽，供特殊召唤。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51205763.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽以表侧攻击表示或里侧守备表示特殊召唤到自己的主要怪兽区；若特殊召唤成功且该怪兽为里侧表示，则执行后续确认。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
		-- 将里侧表示特殊召唤的怪兽向对方玩家确认，使对方知道该卡信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- ②效果的发动条件：这张卡在场上表侧表示时因对方的效果离场，且离场前控制权属于自己。
function c51205763.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 定义②效果从卡组特殊召唤的怪兽的筛选条件：必须是「机怪虫」系列、不是本卡名、且可以里侧守备表示特殊召唤。
function c51205763.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(51205763) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- ②效果的发动条件判定：我方未被「青眼精灵龙」效果限制同时特殊召唤2只以上怪兽，主要怪兽区有至少2个空位，且卡组中存在至少2张卡名不同的符合条件的「机怪虫」怪兽；满足则设置操作信息。
function c51205763.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 确认自己场上主要怪兽区是否有至少2个可用空位，若不足则无法发动。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 从己方卡组中筛选出所有符合条件的「机怪虫」怪兽（非本卡名、可里侧守备特殊召唤）。
		local g=Duel.GetMatchingGroup(c51205763.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置效果处理时将要特殊召唤2只怪兽的操作信息，来源为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- ②效果处理时：再次确认没有「青眼精灵龙」限制且场上空位足够，从卡组选出2只卡名不同的「机怪虫」怪兽，里侧守备表示特殊召唤，并向对方确认。
function c51205763.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时再次检查主要怪兽区空位是否达到2个，不足则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 处理时再次从卡组获取所有符合条件的「机怪虫」怪兽作为候选集合。
	local g=Duel.GetMatchingGroup(c51205763.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示“请选择要特殊召唤的卡”，进入选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从候选卡组中让玩家选择2张卡名互不相同的「机怪虫」怪兽，若选择成功则继续特殊召唤。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的2只怪兽以里侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认这2只里侧守备表示特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,sg)
	end
end
