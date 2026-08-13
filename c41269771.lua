--セイクリッド・グレディ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只4星「星圣」怪兽特殊召唤。
function c41269771.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只4星「星圣」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41269771,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c41269771.sptg)
	e2:SetOperation(c41269771.spop)
	c:RegisterEffect(e2)
	c41269771.star_knight_summon_effect=e2
end
-- 过滤函数：判断手牌中的卡是否满足为4星「星圣」怪兽且能够被特殊召唤。
function c41269771.filter(c,e,tp)
	return c:IsSetCard(0x53) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件的检测：确认主怪兽区有空位，且手牌中存在满足过滤条件的「星圣」4星怪兽。
function c41269771.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查我方主要怪兽区是否有空位，以确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足过滤条件的「星圣」4星怪兽，且该卡不在本次效果已处理的排除集合中。
		and Duel.IsExistingMatchingCard(c41269771.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置操作信息：标明效果处理时将进行特殊召唤，预计从手牌特殊召唤1只怪兽，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：确认仍有空位后，让玩家从手牌选择1只满足条件的「星圣」4星怪兽，并将其表侧表示特殊召唤。
function c41269771.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若主怪兽区没有可用空位，则效果处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择卡片的提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足过滤条件的「星圣」4星怪兽。
	local g=Duel.SelectMatchingCard(tp,c41269771.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
