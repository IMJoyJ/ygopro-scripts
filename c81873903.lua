--エヴォルド・ウェストロ
-- 效果：
-- 反转：从自己卡组把1只名字带有「进化龙」的怪兽特殊召唤。
function c81873903.initial_effect(c)
	-- 反转：从自己卡组把1只名字带有「进化龙」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81873903,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetTarget(c81873903.target)
	e1:SetOperation(c81873903.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中属于「进化龙」系列且可以被特殊召唤的怪兽
function c81873903.filter(c,e,tp)
	return c:IsSetCard(0x604e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与操作信息设置
function c81873903.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数，从卡组选择1只「进化龙」怪兽特殊召唤到场上
function c81873903.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的主要怪兽区域是否有空位，若无空位则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选择1只满足过滤条件的「进化龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c81873903.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
