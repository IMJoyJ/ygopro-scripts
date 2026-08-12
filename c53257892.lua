--ギガプラント
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只昆虫族或者植物族的怪兽特殊召唤。
function c53257892.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只昆虫族或者植物族的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(53257892,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 效果的发动条件为该卡处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c53257892.target)
	e1:SetOperation(c53257892.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足种族为昆虫族或植物族且可以特殊召唤的怪兽
function c53257892.filter(c,e,tp)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动检查函数，判断是否满足发动条件
function c53257892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c53257892.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息，指定将要特殊召唤的卡的来源为手牌和墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果的发动处理函数，执行特殊召唤操作
function c53257892.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或墓地中选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53257892.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
