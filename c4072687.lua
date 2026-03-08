--受け入れがたい結果
-- 效果：
-- ①：自己场上有魔法师族怪兽存在的场合才能发动。从手卡把1只「占卜魔女」怪兽特殊召唤。
function c4072687.initial_effect(c)
	-- 效果原文内容：①：自己场上有魔法师族怪兽存在的场合才能发动。从手卡把1只「占卜魔女」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c4072687.condition)
	e1:SetTarget(c4072687.target)
	e1:SetOperation(c4072687.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查怪兽是否为表侧表示且种族为魔法师族
function c4072687.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 规则层面作用：判断自己场上是否存在魔法师族怪兽
function c4072687.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查自己场上是否存在至少1只魔法师族怪兽
	return Duel.IsExistingMatchingCard(c4072687.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：过滤手卡中可以特殊召唤的「占卜魔女」怪兽
function c4072687.filter(c,e,tp)
	return c:IsSetCard(0x12e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足发动条件，包括场上有空位和手卡有符合条件的怪兽
function c4072687.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查手卡中是否存在符合条件的「占卜魔女」怪兽
		and Duel.IsExistingMatchingCard(c4072687.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置发动时的操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：执行效果的处理流程，包括检查空位、提示选择、选择怪兽并特殊召唤
function c4072687.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：如果自己场上没有空位则不执行效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从手卡中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c4072687.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
