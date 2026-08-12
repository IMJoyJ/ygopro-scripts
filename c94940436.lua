--磁力の召喚円 LV2
-- 效果：
-- 从手卡特殊召唤1只2星以下的机械族怪兽。
function c94940436.initial_effect(c)
	-- 从手卡特殊召唤1只2星以下的机械族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c94940436.target)
	e1:SetOperation(c94940436.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中等级2以下、机械族且可以特殊召唤的怪兽
function c94940436.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查：检查自身场上是否有怪兽区域空位，且手卡中是否存在满足过滤条件的怪兽
function c94940436.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c94940436.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若场上有空位，则让玩家从手卡选择1只满足条件的怪兽特殊召唤
function c94940436.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否仍有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c94940436.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自身场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
