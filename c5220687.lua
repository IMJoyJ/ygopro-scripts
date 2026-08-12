--素早いビッグハムスター
-- 效果：
-- 反转：可以从自己卡组把1只3星以下的兽族怪兽里侧守备表示特殊召唤。
function c5220687.initial_effect(c)
	-- 反转效果，可以特殊召唤1只3星以下的兽族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5220687,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c5220687.target)
	e1:SetOperation(c5220687.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件
function c5220687.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c5220687.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时将要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，筛选3星以下的兽族怪兽且可特殊召唤
function c5220687.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 执行效果处理流程
function c5220687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索满足条件的怪兽
	local g=Duel.GetMatchingGroup(c5220687.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以里侧守备表示特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认被特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
