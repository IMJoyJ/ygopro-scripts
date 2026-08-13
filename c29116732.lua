--デイブレーカー
-- 效果：
-- 这张卡特殊召唤成功时，可以从手卡把1只「破晓者」特殊召唤。
function c29116732.initial_effect(c)
	-- 这张卡特殊召唤成功时，可以从手卡把1只「破晓者」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29116732,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c29116732.sumtg)
	e2:SetOperation(c29116732.sumop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：手牌中卡号29116732（「破晓者」）且能被当前效果特殊召唤的卡。
function c29116732.filter(c,e,tp)
	return c:IsCode(29116732) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件判断与操作信息设定：检查能否发动并设置从手牌特殊召唤的预期。
function c29116732.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己主要怪兽区是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时检查手牌是否存在至少1张满足筛选条件的「破晓者」。
		and Duel.IsExistingMatchingCard(c29116732.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本效果将进行特殊召唤，预告从手牌特殊召唤1只卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时执行特殊召唤：选择手牌中的「破晓者」并特殊召唤。
function c29116732.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己怪兽区有空位，若无空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家从手牌中选择要特殊召唤的「破晓者」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中选出1张满足筛选条件的「破晓者」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c29116732.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「破晓者」以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
