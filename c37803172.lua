--陽炎獣 ペリュトン
-- 效果：
-- 这张卡不能用名字带有「阳炎兽」的怪兽的效果以外特殊召唤。只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，把手卡1只炎属性怪兽送去墓地，把这张卡解放才能发动。从卡组把2只名字带有「阳炎兽」的怪兽特殊召唤。「阳炎兽 佩利冬」的这个效果1回合只能使用1次。
function c37803172.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果为不能成为对方的卡的效果对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这张卡不能用名字带有「阳炎兽」的怪兽的效果以外特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c37803172.splimit)
	c:RegisterEffect(e2)
	-- 发动时支付1只手牌炎属性怪兽的墓地费用并解放自身，从卡组特殊召唤2只名字带有「阳炎兽」的怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37803172,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37803172)
	e3:SetCost(c37803172.spcost)
	e3:SetTarget(c37803172.sptg)
	e3:SetOperation(c37803172.spop)
	c:RegisterEffect(e3)
end
-- 该效果只能被名字带有「阳炎兽」的怪兽的效果特殊召唤
function c37803172.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x107d)
end
-- 过滤手牌中属性为炎且能作为墓地费用的怪兽
function c37803172.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 检查是否满足发动条件：自身可解放且手牌存在1只炎属性怪兽
function c37803172.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查手牌是否存在1只炎属性怪兽
		and Duel.IsExistingMatchingCard(c37803172.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将手牌中1只炎属性怪兽送入墓地作为费用
	Duel.DiscardHand(tp,c37803172.cfilter,1,1,REASON_COST)
	-- 解放自身作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中名字带有「阳炎兽」且能特殊召唤的怪兽
function c37803172.filter(c,e,tp)
	return c:IsSetCard(0x107d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足发动条件：未被【青眼精灵龙】效果影响、场上存在空位、卡组存在2只符合条件的怪兽
function c37803172.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在2只名字带有「阳炎兽」且能特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c37803172.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果：若未被【青眼精灵龙】效果影响且场上存在2个空位，则从卡组选择2只怪兽特殊召唤
function c37803172.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上是否至少存在2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(c37803172.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的2只怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
