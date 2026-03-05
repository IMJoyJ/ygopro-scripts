--隠れ兵
-- 效果：
-- 对方把怪兽召唤·反转召唤时才能发动。从手卡把1只4星以下的暗属性怪兽特殊召唤。
function c2047519.initial_effect(c)
	-- 效果原文内容：对方把怪兽召唤·反转召唤时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c2047519.condition)
	e1:SetTarget(c2047519.target)
	e1:SetOperation(c2047519.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：从手卡把1只4星以下的暗属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetCondition(c2047519.condition)
	e2:SetTarget(c2047519.target)
	e2:SetOperation(c2047519.activate)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断发动玩家是否为对方玩家
function c2047519.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 规则层面作用：过滤满足条件的卡片组，包括等级4以下、暗属性且可特殊召唤的怪兽
function c2047519.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置连锁处理的目标信息，确定将要特殊召唤的卡
function c2047519.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c2047519.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面作用：设置当前处理的连锁操作信息，用于后续效果处理检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面作用：执行效果的处理流程，包括选择并特殊召唤符合条件的怪兽
function c2047519.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从玩家手牌中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c2047519.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
