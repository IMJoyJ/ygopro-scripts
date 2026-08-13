--狩猟本能
-- 效果：
-- 对方场上有怪兽特殊召唤时才能发动。从手卡特殊召唤1只恐龙族怪兽。
function c11925569.initial_effect(c)
	-- 对方场上有怪兽特殊召唤时才能发动。从手卡特殊召唤1只恐龙族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c11925569.condition)
	e1:SetTarget(c11925569.target)
	e1:SetOperation(c11925569.activate)
	c:RegisterEffect(e1)
end
-- 检查特殊召唤成功的怪兽中是否存在对方场上的怪兽（至少1只），即触发条件为该次特殊召唤包含对方场上的怪兽。
function c11925569.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 筛选可用于特殊召唤的怪兽：必须是恐龙族，且能够被当前效果正常特殊召唤（满足苏生限制和召唤条件）。
function c11925569.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性的目标判断：我方主要怪兽区有空位，并且手牌存在至少1只符合条件的恐龙族怪兽。
function c11925569.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查（chk==0）时，确认我方主要怪兽区域是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认手牌中存在至少1只满足条件（恐龙族且可被特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c11925569.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 将本次操作信息登记为：从手牌将1只怪兽特殊召唤，用于后续时点/连锁的判定及相关效果互动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：从手牌选择1只符合条件的恐龙族怪兽，以表侧表示特殊召唤到我方场上。
function c11925569.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查我方主要怪兽区是否还有空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选出所有符合条件的恐龙族怪兽，并让玩家选择其中1张作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c11925569.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到发起效果的玩家（tp）的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
