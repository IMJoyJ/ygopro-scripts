--電池メン－単四型
-- 效果：
-- 这张卡召唤·反转时，可以把自己的手卡·墓地存在的1只「电池人-单四型」特殊召唤。
function c47346845.initial_effect(c)
	-- 这张卡召唤时，可以把自己的手卡·墓地存在的1只「电池人-单四型」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47346845,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c47346845.sumtg)
	e1:SetOperation(c47346845.sumop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
end
-- 过滤函数：选择手卡·墓地中卡名为「电池人-单四型」且能够被当前效果特殊召唤的卡。
function c47346845.filter(c,e,tp)
	return c:IsCode(47346845) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件：自己场上主要怪兽区有空位，且手卡·墓地存在1只符合条件的「电池人-单四型」。
function c47346845.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定效果发动时（chk==0）需要满足：自己场上主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时需要手卡·墓地中存在1只满足filter的「电池人-单四型」可作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c47346845.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果为特殊召唤，预计从手卡·墓地特殊召唤1只怪兽（具体对象在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理时：先确认主要怪兽区仍有空位，提示玩家从手卡·墓地选择1只符合条件的「电池人-单四型」，并将其特殊召唤。
function c47346845.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若主要怪兽区已无空位，则直接终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1张满足filter且不受王家长眠之谷影响的「电池人-单四型」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c47346845.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「电池人-单四型」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
