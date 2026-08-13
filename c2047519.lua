--隠れ兵
-- 效果：
-- 对方把怪兽召唤·反转召唤时才能发动。从手卡把1只4星以下的暗属性怪兽特殊召唤。
function c2047519.initial_effect(c)
	-- 对方把怪兽召唤时才能发动。从手卡把1只4星以下的暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c2047519.condition)
	e1:SetTarget(c2047519.target)
	e1:SetOperation(c2047519.activate)
	c:RegisterEffect(e1)
	-- 对方把怪兽反转召唤时才能发动。从手卡把1只4星以下的暗属性怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetCondition(c2047519.condition)
	e2:SetTarget(c2047519.target)
	e2:SetOperation(c2047519.activate)
	c:RegisterEffect(e2)
end
-- 判断触发召唤/反转召唤的玩家是否为对方（ep不等于tp），即只有对方召唤/反转召唤怪兽时本效果才能发动。
function c2047519.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 筛选可特殊召唤的手卡怪兽：等级4以下、暗属性，且满足当前效果的特殊召唤条件（可被特殊召唤）。
function c2047519.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性的判定：己方主要怪兽区有空位，且手卡存在1只以上满足筛选条件的怪兽，则效果可以发动。
function c2047519.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有空闲区域，确保有地方特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足等级4以下、暗属性且可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c2047519.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：此效果将从手卡特殊召唤1只怪兽（用于后续连锁检测等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：在仍有可用的主要怪兽区域时，从手卡选择1只符合条件的暗属性怪兽，以表侧表示特殊召唤到己方场上。
function c2047519.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区已无空位，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡筛选并选择1只满足条件（4星以下、暗属性、可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c2047519.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
