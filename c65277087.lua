--ガスタ・ガルド
-- 效果：
-- 这张卡从场上送去墓地时，可以从自己卡组把1只2星以下的名字带有「薰风」的怪兽特殊召唤。
function c65277087.initial_effect(c)
	-- 这张卡从场上送去墓地时，可以从自己卡组把1只2星以下的名字带有「薰风」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65277087,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c65277087.condition)
	e1:SetTarget(c65277087.target)
	e1:SetOperation(c65277087.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡送去墓地前的位置是否在场上
function c65277087.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中等级2以下、名字带有「薰风」且可以特殊召唤的怪兽
function c65277087.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与操作信息设置
function c65277087.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查自己卡组是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c65277087.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只满足条件的「薰风」怪兽特殊召唤
function c65277087.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查自己场上是否仍有空余的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c65277087.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
