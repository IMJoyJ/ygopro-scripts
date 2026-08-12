--ガスタ・スクイレル
-- 效果：
-- 这张卡被卡的效果破坏送去墓地时，可以从自己卡组把1只5星以上的名字带有「薰风」的怪兽特殊召唤。
function c336369.initial_effect(c)
	-- 诱发选发效果，破坏送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(336369,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c336369.condition)
	e1:SetTarget(c336369.target)
	e1:SetOperation(c336369.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的发动条件，破坏原因包含REASON_EFFECT和REASON_DESTROY
function c336369.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41
end
-- 过滤函数，用于筛选5星以上且名字带有「薰风」的怪兽
function c336369.filter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c336369.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c336369.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行特殊召唤操作
function c336369.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家卡组中选择满足条件的1只怪兽
	local g = Duel.SelectMatchingCard(tp,c336369.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
