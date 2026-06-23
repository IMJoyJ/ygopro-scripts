--ぴよコッコ
-- 效果：
-- 反转：可以从卡组把1只5星以上的调整特殊召唤。
function c27189308.initial_effect(c)
	-- 反转效果，发动时可以特殊召唤1只5星以上的调整
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c27189308.target)
	e1:SetOperation(c27189308.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的处理，判断是否满足发动条件
function c27189308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家卡组中是否存在满足条件的调整
		and Duel.IsExistingMatchingCard(c27189308.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，筛选5星以上且为调整的卡
function c27189308.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时执行的操作
function c27189308.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检索满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(c27189308.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
