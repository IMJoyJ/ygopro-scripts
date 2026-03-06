--督戦官コヴィントン
-- 效果：
-- ①：把自己场上的表侧表示的「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只送去墓地才能发动。从手卡·卡组把1只「机甲部队·武装力量」特殊召唤。
function c22666164.initial_effect(c)
	-- 效果原文内容：①：把自己场上的表侧表示的「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只送去墓地才能发动。从手卡·卡组把1只「机甲部队·武装力量」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22666164,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c22666164.cost)
	e1:SetTarget(c22666164.target)
	e1:SetOperation(c22666164.operation)
	c:RegisterEffect(e1)
end
-- 创建一个检查函数数组，用于验证是否满足「机甲士兵」「机甲狙击兵」「机甲卫兵」各1只的条件
c22666164.spchecks=aux.CreateChecks(Card.IsCode,{60999392,23782705,96384007})
-- 过滤函数，用于筛选场上表侧表示且能作为cost送去墓地的「机甲士兵」「机甲狙击兵」「机甲卫兵」
function c22666164.spcostfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsCode(60999392,23782705,96384007)
end
-- 效果处理函数，检查是否有满足条件的怪兽并选择将其送去墓地作为代价
function c22666164.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上满足条件的「机甲士兵」「机甲狙击兵」「机甲卫兵」怪兽组
	local g=Duel.GetMatchingGroup(c22666164.spcostfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查场上是否存在满足条件的怪兽组（即各1只）
	if chk==0 then return g:CheckSubGroupEach(c22666164.spchecks,aux.mzctcheck,tp) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽组（各1只）
	local sg=g:SelectSubGroupEach(tp,c22666164.spchecks,false,aux.mzctcheck,tp)
	-- 将选中的怪兽送去墓地作为发动代价
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 过滤函数，用于筛选「机甲部队·武装力量」怪兽
function c22666164.filter(c,e,tp)
	return c:IsCode(58054262) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 效果目标函数，检查是否满足特殊召唤条件
function c22666164.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区空位（至少3个）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-3
		-- 检查手卡或卡组中是否存在「机甲部队·武装力量」
		and Duel.IsExistingMatchingCard(c22666164.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只「机甲部队·武装力量」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数，选择并特殊召唤「机甲部队·武装力量」
function c22666164.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只「机甲部队·武装力量」怪兽
	local g=Duel.SelectMatchingCard(tp,c22666164.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
