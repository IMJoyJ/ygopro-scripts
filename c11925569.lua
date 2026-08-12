--狩猟本能
-- 效果：
-- 对方场上有怪兽特殊召唤时才能发动。从手卡特殊召唤1只恐龙族怪兽。
function c11925569.initial_effect(c)
	-- 创建效果，设置为发动时点，条件为对方怪兽特殊召唤成功，目标为选择一只恐龙族怪兽特殊召唤，效果为特殊召唤恐龙族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c11925569.condition)
	e1:SetTarget(c11925569.target)
	e1:SetOperation(c11925569.activate)
	c:RegisterEffect(e1)
end
-- 对方场上有怪兽特殊召唤时才能发动
function c11925569.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤手卡中满足条件的恐龙族怪兽（可以被特殊召唤）
function c11925569.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的条件，检查是否满足特殊召唤条件
function c11925569.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少一张恐龙族怪兽
		and Duel.IsExistingMatchingCard(c11925569.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张恐龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时处理特殊召唤的逻辑
function c11925569.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否还有空位，没有则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从手卡中选择一只恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c11925569.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的恐龙族怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
