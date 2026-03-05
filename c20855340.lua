--エヴォルド・プレウロス
-- 效果：
-- 这张卡在自己场上被破坏送去墓地的场合，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
function c20855340.initial_effect(c)
	-- 效果原文：这张卡在自己场上被破坏送去墓地的场合，可以从手卡把1只名字带有「进化龙」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20855340,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c20855340.condition)
	e1:SetTarget(c20855340.target)
	e1:SetOperation(c20855340.operation)
	c:RegisterEffect(e1)
end
-- 规则层面：检查此卡是否从场上被破坏送去墓地
function c20855340.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp)
		and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 规则层面：过滤手卡中名字带有「进化龙」且可以特殊召唤的怪兽
function c20855340.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面：判断是否满足发动条件，即场上有空位且手卡有符合条件的怪兽
function c20855340.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：判断手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c20855340.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 规则层面：执行效果处理，检查是否有空位并选择特殊召唤的怪兽
function c20855340.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：如果场上没有空位则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面：从手卡选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c20855340.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面：将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
