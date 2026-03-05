--スプライト・スターター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「卫星闪灵」怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这张卡的发动后，直到回合结束时自己不是2星·2阶·连接2的怪兽不能特殊召唤。
function c15443125.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15443125+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c15443125.target)
	e1:SetOperation(c15443125.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的「卫星闪灵」怪兽
function c15443125.filter(c,e,tp)
	return c:IsSetCard(0x180) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动条件
function c15443125.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c15443125.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果原文内容：①：从卡组把1只「卫星闪灵」怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。
function c15443125.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c15443125.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 效果作用：将选中的怪兽特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果作用：获取当前玩家的基本分
		local lp=Duel.GetLP(tp)
		-- 效果作用：扣除选中怪兽攻击力数值的基本分
		Duel.SetLP(tp,lp-tc:GetBaseAttack())
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 效果原文内容：这张卡的发动后，直到回合结束时自己不是2星·2阶·连接2的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c15443125.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：限制不是2星·2阶·连接2的怪兽不能特殊召唤
function c15443125.splimit(e,c)
	return not c:IsLevel(2) and not c:IsRank(2) and not c:IsLink(2)
end
