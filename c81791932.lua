--スネーク・ホイッスル
-- 效果：
-- 自己场上存在的爬虫类族怪兽被破坏时才能发动。从自己卡组把1只4星以下的爬虫类族怪兽在自己场上特殊召唤。
function c81791932.initial_effect(c)
	-- 自己场上存在的爬虫类族怪兽被破坏时才能发动。从自己卡组把1只4星以下的爬虫类族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c81791932.condition)
	e1:SetTarget(c81791932.target)
	e1:SetOperation(c81791932.activate)
	c:RegisterEffect(e1)
end
-- 过滤被破坏的卡：自己场上表侧表示存在的爬虫类族怪兽。
function c81791932.cfilter(c,tp)
	return c:IsRace(RACE_REPTILE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查被破坏的怪兽中是否存在满足条件的自己场上的表侧表示爬虫类族怪兽。
function c81791932.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81791932.cfilter,1,nil,tp)
end
-- 过滤卡组中满足条件的卡：4星以下的爬虫类族怪兽，且可以特殊召唤。
function c81791932.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与检测：检查自身怪兽区域是否有空位，以及卡组中是否存在可特殊召唤的4星以下爬虫类族怪兽，并设置特殊召唤的操作信息。
function c81791932.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c81791932.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从自己卡组将1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行：在自己场上有空位的情况下，从卡组选择1只满足条件的怪兽在自己场上表侧表示特殊召唤。
function c81791932.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空位，若无则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c81791932.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽在自己场上以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
