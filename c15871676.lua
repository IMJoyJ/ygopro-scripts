--セイクリッド・ダバラン
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的3星怪兽特殊召唤。
function c15871676.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的3星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15871676,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c15871676.sptg)
	e2:SetOperation(c15871676.spop)
	c:RegisterEffect(e2)
	c15871676.star_knight_summon_effect=e2
end
-- 筛选满足条件的卡：卡名属于「星圣」系列、等级为3，且可以被效果特殊召唤。
function c15871676.filter(c,e,tp)
	return c:IsSetCard(0x53) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件的检查：确认自己主要怪兽区有空位，并且手牌中存在满足条件的可特殊召唤怪兽。
function c15871676.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查自己主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足筛选条件的「星圣」3星怪兽（exc为需要排除的卡）。
		and Duel.IsExistingMatchingCard(c15871676.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置本次效果的操作信息：从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：先确认怪兽区有空位，提示玩家选择手牌中符合条件的怪兽，然后将其特殊召唤。
function c15871676.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若主要怪兽区无空位，则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足条件的「星圣」3星怪兽。
	local g=Duel.SelectMatchingCard(tp,c15871676.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
