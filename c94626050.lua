--フィッシュ・レイン
-- 效果：
-- 场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时才能发动。从自己手卡把1只3星以下的鱼族·海龙族·水族怪兽特殊召唤。
function c94626050.initial_effect(c)
	-- 场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时才能发动。从自己手卡把1只3星以下的鱼族·海龙族·水族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c94626050.condition)
	e1:SetTarget(c94626050.target)
	e1:SetOperation(c94626050.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：原本在场上表侧表示存在的鱼族、海龙族或水族怪兽
function c94626050.cfilter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 发动条件：检查被除外的卡片中是否存在满足条件的怪兽
function c94626050.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c94626050.cfilter,1,nil)
end
-- 过滤条件：手卡中等级3以下且可以特殊召唤的鱼族、海龙族或水族怪兽
function c94626050.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检测与操作信息设置
function c94626050.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c94626050.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡特殊召唤1只满足条件的怪兽
function c94626050.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否仍有空位，若无则直接结束处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c94626050.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
