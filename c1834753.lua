--マックス・テレポーター
-- 效果：
-- 这张卡不能特殊召唤。可以支付2000基本分，从自己卡组把2只3星的念动力族怪兽在自己场上特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c1834753.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 可以支付2000基本分，从自己卡组把2只3星的念动力族怪兽在自己场上特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1834753,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c1834753.spcost)
	e2:SetTarget(c1834753.sptg)
	e2:SetOperation(c1834753.spop)
	c:RegisterEffect(e2)
end
-- 支付2000基本分
function c1834753.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分
	Duel.PayLPCost(tp,2000)
end
-- 过滤满足3星、念动力族且可以特殊召唤的怪兽
function c1834753.filter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测是否满足特殊召唤条件：未受青眼精灵龙影响、场上至少有2个空怪兽区、卡组存在至少2只符合条件的怪兽
function c1834753.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上是否有至少2个空怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c1834753.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作
function c1834753.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查场上是否至少有2个空怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c1834753.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
