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
-- 过滤函数，用于判断手卡中是否有一只可以特殊召唤的「破晓者」
function c29116732.filter(c,e,tp)
	return c:IsCode(29116732) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查手卡是否有满足条件的「破晓者」且场上存在空位
function c29116732.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的「破晓者」
		and Duel.IsExistingMatchingCard(c29116732.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的类型和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c29116732.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位以进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择一只满足条件的「破晓者」
	local g=Duel.SelectMatchingCard(tp,c29116732.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「破晓者」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
