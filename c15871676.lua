--セイクリッド・ダバラン
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「星圣」的3星怪兽特殊召唤。
function c15871676.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15871676,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c15871676.sptg)
	e2:SetOperation(c15871676.spop)
	c:RegisterEffect(e2)
	c15871676.star_knight_summon_effect=e2
end
-- 过滤函数，用于筛选手牌中名字带有「星圣」且等级为3的怪兽，且可以被特殊召唤
function c15871676.filter(c,e,tp)
	return c:IsSetCard(0x53) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查是否满足特殊召唤的条件
function c15871676.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查玩家场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c15871676.filter,tp,LOCATION_HAND,0,1,exc,e,tp) end
	-- 设置效果处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c15871676.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有可用的怪兽区域，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c15871676.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
