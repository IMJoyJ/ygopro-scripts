--クローラー・アクソン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡反转的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「机怪虫·轴突虫」以外的2只「机怪虫」怪兽从卡组里侧守备表示特殊召唤（同名卡最多1张）。
function c15710054.initial_effect(c)
	-- ①：这张卡反转的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
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
-- 选择场上1张魔法·陷阱卡作为对象
function c15710054.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c15710054.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤条件
function c15710054.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
-- 过滤出符合条件的「机怪虫」怪兽
function c15710054.filter1(c,e,tp)
	return c:IsSetCard(0x104) and not c:IsCode(15710054) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 判断是否满足特殊召唤条件
function c15710054.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		-- 检查场上是否有足够的召唤区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return false end
		-- 从卡组中筛选符合条件的怪兽
		local g=Duel.GetMatchingGroup(c15710054.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=2
	end
	-- 设置效果处理信息，确定要特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤效果
function c15710054.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从卡组中筛选符合条件的怪兽
	local g=Duel.GetMatchingGroup(c15710054.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从符合条件的怪兽中选择2只不同卡名的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
