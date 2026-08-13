--マックス・テレポーター
-- 效果：
-- 这张卡不能特殊召唤。可以支付2000基本分，从自己卡组把2只3星的念动力族怪兽在自己场上特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c1834753.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的值设为false，使这只怪兽无法通过任何方式特殊召唤。
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
-- 该效果发动前需要支付2000基本分作为代价，此函数负责检查并实际支付LP。
function c1834753.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家能否支付2000基本分，若不能则效果无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 实际支付2000基本分作为发动代价。
	Duel.PayLPCost(tp,2000)
end
-- 定义可特殊召唤的怪兽条件：等级3、念动力族、并且能够被该效果特殊召唤。
function c1834753.filter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时判定是否满足条件：不在青眼精灵龙效果影响下、自己有至少2个可用怪兽区域、卡组存在至少2只符合条件的怪兽。
function c1834753.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己的主要怪兽区域空位大于1个，以确保能特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认卡组中存在至少2只满足filter筛选条件的3星念动力族怪兽。
		and Duel.IsExistingMatchingCard(c1834753.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置操作信息，标明本次效果将从卡组特殊召唤2只怪兽，用于连锁判定和时点触发。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：若青眼精灵龙效果适用或可用怪兽区域不足2个则直接终止；否则从卡组选择2只符合条件的3星念动力族怪兽正面表示特殊召唤。
function c1834753.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认己方主要怪兽区域空位不少于2个，防止区域因其他原因减少后无法处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 从卡组中获取所有满足3星、念动力族且可特殊召唤的怪兽集合。
	local g=Duel.GetMatchingGroup(c1834753.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 给玩家显示选择提示“请选择要特殊召唤的卡”，引导玩家从符合条件的怪兽中选取。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选出的2只怪兽以正面表示特殊召唤到己方场上，完成从卡组特殊召唤的操作。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
