--ぴよコッコ
-- 效果：
-- 反转：可以从卡组把1只5星以上的调整特殊召唤。
function c27189308.initial_effect(c)
	-- 反转：可以从卡组把1只5星以上的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c27189308.target)
	e1:SetOperation(c27189308.operation)
	c:RegisterEffect(e1)
end
-- Target函数：在效果发动时检查是否满足特殊召唤条件，即主要怪兽区有空位且卡组存在符合条件的调整怪兽。
function c27189308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位，作为效果发动的必要条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足筛选条件的卡（5星以上、调整、可特殊召唤），作为效果发动的另一条件。
		and Duel.IsExistingMatchingCard(c27189308.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：宣告本效果将进行从卡组特殊召唤1只怪兽，供系统和其他卡效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义筛选函数：选择等级5以上、调整怪兽、并且可被当前效果特殊召唤的卡。
function c27189308.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 操作函数：效果处理时，若主要怪兽区仍有空位，则从卡组中选出1只符合条件的调整怪兽，以表侧表示特殊召唤。
function c27189308.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查主要怪兽区是否仍有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中全部满足筛选条件的卡，作为可特殊召唤的候选集合。
	local g=Duel.GetMatchingGroup(c27189308.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 向玩家显示选择提示，要求从候选中选择1只要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择到的卡以表侧表示特殊召唤到自己场上（同时不无视召唤条件与苏生限制）。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
