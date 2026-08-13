--召喚師セームベル
-- 效果：
-- 自己的主要阶段时，可以把和这张卡相同等级的1只怪兽从手卡特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c45282603.initial_effect(c)
	-- 自己的主要阶段时，可以把和这张卡相同等级的1只怪兽从手卡特殊召唤。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45282603,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCountLimit(1)
	e1:SetTarget(c45282603.sptg)
	e1:SetOperation(c45282603.spop)
	c:RegisterEffect(e1)
end
-- 筛选手牌中的怪兽：要求等级与发动效果的这张卡相同，且能被当前效果特殊召唤。
function c45282603.filter(c,lv,e,tp)
	return c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件的判定：自己主要怪兽区有空位，且手牌中存在满足条件的怪兽时才能发动。
function c45282603.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只等级与这张卡相同且可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c45282603.filter,tp,LOCATION_HAND,0,1,nil,e:GetHandler():GetLevel(),e,tp) end
	-- 设置本次效果处理的信息：预定从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：确认条件后选择并特殊召唤手牌中符合条件的怪兽。
function c45282603.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空格，若无空格则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足等级相同且可被特殊召唤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c45282603.filter,tp,LOCATION_HAND,0,1,1,nil,e:GetHandler():GetLevel(),e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
