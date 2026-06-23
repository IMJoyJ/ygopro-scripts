--超戦士の萌芽
-- 效果：
-- 「混沌战士」仪式怪兽的降临必需。「超战士的萌芽」在1回合只能发动1张。
-- ①：等级合计直到8的以下其中1个组合的怪兽送去墓地，从自己的手卡·墓地把1只「混沌战士」仪式怪兽仪式召唤。
-- ●手卡1只光属性怪兽和卡组1只暗属性怪兽
-- ●手卡1只暗属性怪兽和卡组1只光属性怪兽
function c45948430.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点，只能发动一次，目标为特殊召唤和从卡组送去墓地
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45948430+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c45948430.target)
	e1:SetOperation(c45948430.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手卡或墓地的「混沌战士」仪式怪兽是否可以被仪式召唤
function c45948430.filter(c,e,tp)
	if not c:IsSetCard(0x10cf) or bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	-- 检查是否存在满足条件的光暗属性手卡怪兽作为仪式召唤的素材
	return Duel.IsExistingMatchingCard(c45948430.matfilter1,tp,LOCATION_HAND,0,1,c,tp,c)
end
-- 过滤函数，检查手卡中是否含有光暗属性且等级不超过7的怪兽，并且能作为仪式素材
function c45948430.matfilter1(c,tp,rc)
	return c:IsLevelBelow(7) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
		-- 检查是否存在满足条件的卡组怪兽作为仪式召唤的另一组素材
		and Duel.IsExistingMatchingCard(c45948430.matfilter2,tp,LOCATION_DECK,0,1,c,c:GetLevel(),c:GetAttribute(),rc)
end
-- 过滤函数，检查卡组中是否含有与指定属性相反且等级为8-指定等级的怪兽
function c45948430.matfilter2(c,lv,att,rc)
	return ((c:IsAttribute(ATTRIBUTE_LIGHT) and att==ATTRIBUTE_DARK) or (c:IsAttribute(ATTRIBUTE_DARK) and att==ATTRIBUTE_LIGHT))
		and c:IsLevel(8-lv) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
end
-- 效果发动时的处理函数，检查是否满足发动条件并设置操作信息
function c45948430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家场上是否有足够的空间进行特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡或墓地中是否存在满足条件的「混沌战士」仪式怪兽
			and Duel.IsExistingMatchingCard(c45948430.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	-- 设置操作信息，表示将要特殊召唤1只怪兽，来源为手卡或墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 检查函数，用于筛选满足条件的2张怪兽作为仪式召唤的素材
function c45948430.check(g)
	-- 检查组中所有卡片属性不同、位置不同且等级总和为8
	return aux.dabcheck(g) and g:GetClassCount(Card.GetLocation)==#g and g:GetSum(Card.GetLevel)==8
end
-- 过滤函数，检查卡组或手卡中是否含有光暗属性且等级不超过7的怪兽
function c45948430.mfilter(c,rc)
	return c:IsLevelBelow(7) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave() and c:IsCanBeRitualMaterial(rc)
end
-- 效果发动处理函数，执行仪式召唤流程
function c45948430.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	::cancel::
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「混沌战士」仪式怪兽
	local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45948430.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local rc=rg:GetFirst()
	if rc then
		-- 获取所有满足条件的卡组或手卡怪兽作为仪式召唤的素材候选
		local mg=Duel.GetMatchingGroup(c45948430.mfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,rc)
		-- 提示玩家选择要送去墓地的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local mat=mg:SelectSubGroup(tp,c45948430.check,true,2,2)
		if not mat then goto cancel end
		rc:SetMaterial(mat)
		-- 将选中的怪兽送去墓地作为仪式召唤的素材
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 将选中的怪兽以仪式召唤方式特殊召唤到场上
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end
