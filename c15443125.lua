--スプライト・スターター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「卫星闪灵」怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这张卡的发动后，直到回合结束时自己不是2星·2阶·连接2的怪兽不能特殊召唤。
function c15443125.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「卫星闪灵」怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这张卡的发动后，直到回合结束时自己不是2星·2阶·连接2的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15443125+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c15443125.target)
	e1:SetOperation(c15443125.activate)
	c:RegisterEffect(e1)
end
-- 筛选卡组中持有「卫星闪灵」字段、且能被当前效果特殊召唤的怪兽。
function c15443125.filter(c,e,tp)
	return c:IsSetCard(0x180) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的合法性检查：自己主要怪兽区有空位，且卡组中存在符合条件的「卫星闪灵」怪兽。
function c15443125.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足筛选条件的「卫星闪灵」怪兽。
		and Duel.IsExistingMatchingCard(c15443125.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次效果处理的信息：预定从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选1只「卫星闪灵」怪兽特殊召唤，成功则扣除其原本攻击力数值的LP，并在回合结束前附加自肃。
function c15443125.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区已无空位，则不进行后续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给出“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1张满足filter条件的「卫星闪灵」怪兽。
	local g=Duel.SelectMatchingCard(tp,c15443125.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选中的怪兽存在且特殊召唤成功，则进入扣LP处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取当前LP。
		local lp=Duel.GetLP(tp)
		-- 扣除该怪兽原本攻击力数值的LP。
		Duel.SetLP(tp,lp-tc:GetBaseAttack())
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是2星·2阶·连接2的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c15443125.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，作用于该玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 判断怪兽是否不是2星、2阶、连接2；满足则该怪兽不能特殊召唤。
function c15443125.splimit(e,c)
	return not c:IsLevel(2) and not c:IsRank(2) and not c:IsLink(2)
end
