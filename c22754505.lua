--スモール・ピース・ゴーレム
-- 效果：
-- 自己场上有「大块石人」表侧表示存在的场合这张卡召唤·反转召唤·特殊召唤成功时，可以从自己卡组把1只「中块石人」特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c22754505.initial_effect(c)
	-- 自己场上有「大块石人」表侧表示存在的场合这张卡召唤·反转召唤·特殊召唤成功时，可以从自己卡组把1只「中块石人」特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22754505,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c22754505.spcon)
	e1:SetTarget(c22754505.sptg)
	e1:SetOperation(c22754505.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡c是否为表侧表示且卡名为「大块石人」（25247218）。
function c22754505.cfilter(c)
	return c:IsFaceup() and c:IsCode(25247218)
end
-- 效果发动条件：自己场上存在表侧表示的「大块石人」时，本效果才满足发动条件。
function c22754505.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「大块石人」。
	return Duel.IsExistingMatchingCard(c22754505.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：判断卡c是否为「中块石人」（58843503）且能够被玩家tp特殊召唤。
function c22754505.filter(c,e,tp)
	return c:IsCode(58843503) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理：检查自己主要怪兽区有空位，且卡组中存在可特殊召唤的「中块石人」，满足则效果可以发动。
function c22754505.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且确认卡组中存在1只满足特殊召唤条件的「中块石人」。
		and Duel.IsExistingMatchingCard(c22754505.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：向系统登记本次效果将执行从卡组特殊召唤1只怪兽的处理，用于连锁判定等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从自己卡组选择1只「中块石人」特殊召唤，并使其效果无效化。
function c22754505.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区仍有空位，若没有空位则效果处理中止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己卡组选择1张符合条件的「中块石人」。
	local g=Duel.SelectMatchingCard(tp,c22754505.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选到「中块石人」且特殊召唤步骤成功，则进入后续的效果无效化处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤连锁处理，正式结算所有通过SpecialSummonStep进行的特殊召唤。
	Duel.SpecialSummonComplete()
end
