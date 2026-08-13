--ギガプラント
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只昆虫族或者植物族的怪兽特殊召唤。
function c53257892.initial_effect(c)
	-- 为这张卡添加二重怪兽属性，使其在场上·墓地存在时当作通常怪兽使用，并支持后续的再度召唤机制。
	aux.EnableDualAttribute(c)
	-- 对应效果原文：●1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只昆虫族或者植物族的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetDescription(aux.Stringid(53257892,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置效果的发动条件：只有这张卡处于二重怪兽的再度召唤状态（即当作效果怪兽使用）时才能发动。
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c53257892.target)
	e1:SetOperation(c53257892.operation)
	c:RegisterEffect(e1)
end
-- 定义可选择的怪兽的过滤条件：必须是昆虫族或植物族怪兽，并且能够被当前效果特殊召唤（满足特殊召唤限制）。
function c53257892.filter(c,e,tp)
	return c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择函数：检查阶段判断场上是否有空位且手卡/墓地是否存在符合条件的怪兽。
function c53257892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域，以保证后续特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少1只满足过滤条件的昆虫族或植物族怪兽。
		and Duel.IsExistingMatchingCard(c53257892.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，宣布本效果处理涉及特殊召唤分类，不取对象，预计从自己的手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理时的执行函数：确认空位后，由玩家选择符合条件的怪兽并特殊召唤。
function c53257892.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否仍有空余的怪兽区域，若没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡·墓地选择1张满足过滤条件且不受王家长眠之谷影响的昆虫族或植物族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53257892.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（遵守召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
