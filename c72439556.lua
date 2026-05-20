--ガスタの希望 カムイ
-- 效果：
-- 反转：从自己卡组把1只名字带有「薰风」的调整特殊召唤。
function c72439556.initial_effect(c)
	-- 反转：从自己卡组把1只名字带有「薰风」的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72439556,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c72439556.target)
	e1:SetOperation(c72439556.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中名字带有「薰风」且可以特殊召唤的调整怪兽
function c72439556.filter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 反转效果的发动准备，设置特殊召唤的操作信息
function c72439556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 反转效果的执行，从卡组将1只「薰风」调整怪兽特殊召唤到场上
function c72439556.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若无空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选择1只满足条件的「薰风」调整怪兽
	local g=Duel.SelectMatchingCard(tp,c72439556.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
