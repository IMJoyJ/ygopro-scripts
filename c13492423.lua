--フォトン・カイザー
-- 效果：
-- 这张卡召唤·反转召唤成功时，可以从自己的手卡·卡组把1只「光子帝王」特殊召唤。
function c13492423.initial_effect(c)
	-- 这张卡召唤·反转召唤成功时，可以从自己的手卡·卡组把1只「光子帝王」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13492423,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c13492423.sptg)
	e1:SetOperation(c13492423.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检查卡片是否为「光子帝王」（卡号13492423）且能够被效果特殊召唤，作为手卡·卡组中的候选对象。
function c13492423.filter(c,e,tp)
	return c:IsCode(13492423) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时（chk==0）判定能否发动：要求自己主要怪兽区有空位，且手卡·卡组存在1只符合条件的「光子帝王」。
function c13492423.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上主要怪兽区是否有可用空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡·卡组中是否存在至少1只满足filter条件的「光子帝王」。
		and Duel.IsExistingMatchingCard(c13492423.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果将进行特殊召唤的操作信息：来源为手卡·卡组，数量为1，操作者为发动者。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理阶段：若场上仍有空位，则提示玩家从手卡·卡组选择1只符合条件的「光子帝王」，将其表侧表示特殊召唤到自己场上。
function c13492423.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区仍有空位，若已无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示消息，用于选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组中选取1张满足filter条件的「光子帝王」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c13492423.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「光子帝王」以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
