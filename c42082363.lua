--ガスタ・グリフ
-- 效果：
-- 这张卡从手卡送去墓地的场合，可以从自己卡组把1只名字带有「薰风」的怪兽特殊召唤。「薰风狮鹫」的效果1回合只能使用1次。
function c42082363.initial_effect(c)
	-- 效果原文内容：这张卡从手卡送去墓地的场合，可以从自己卡组把1只名字带有「薰风」的怪兽特殊召唤。「薰风狮鹫」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42082363,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,42082363)
	e1:SetCondition(c42082363.condition)
	e1:SetTarget(c42082363.target)
	e1:SetOperation(c42082363.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断此卡是否由手卡送去墓地
function c42082363.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 规则层面作用：过滤满足条件的「薰风」怪兽（名字带有「薰风」且可以特殊召唤）
function c42082363.filter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足发动条件（场上有空位且卡组存在符合条件的怪兽）
function c42082363.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c42082363.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行特殊召唤操作
function c42082363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c42082363.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
