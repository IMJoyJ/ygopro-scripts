--月光蝶
-- 效果：
-- 这张卡从场上送去墓地时，可以从卡组把1只4星以下的名字带有「幻蝶刺客」的怪兽特殊召唤。
function c16366944.initial_effect(c)
	-- 这张卡从场上送去墓地时，可以从卡组把1只4星以下的名字带有「幻蝶刺客」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16366944,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c16366944.condition)
	e1:SetTarget(c16366944.target)
	e1:SetOperation(c16366944.operation)
	c:RegisterEffect(e1)
end
-- 判断这张卡是否是从场上被送去墓地（即送去墓地前位于场上）。
function c16366944.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义可特殊召唤的卡牌条件：等级4以下、持有『幻蝶刺客』字段、且能够特殊召唤。
function c16366944.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x6a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检查与目标设定：确认我方主怪兽区有空位且卡组存在符合条件的怪兽，并设置操作信息为从卡组特殊召唤1只怪兽。
function c16366944.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，首先要求我方主要怪兽区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在1只满足条件的怪兽（等级4以下、幻蝶刺客字段、可特殊召唤）。
		and Duel.IsExistingMatchingCard(c16366944.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果将进行特殊召唤操作，预计从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：确认仍有空位后，从卡组选择1只符合条件的怪兽，以表侧表示特殊召唤到我方场上。
function c16366944.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方主要怪兽区域有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示，请其选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方卡组中筛选并选择1只满足条件的怪兽（等级4以下、幻蝶刺客字段、可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c16366944.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
