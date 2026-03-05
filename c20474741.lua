--トライデント・ウォリアー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只3星怪兽特殊召唤。
function c20474741.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20474741,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c20474741.sumtg)
	e2:SetOperation(c20474741.sumop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中等级为3且可以被特殊召唤的怪兽
function c20474741.filter(c,e,tp)
	return c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查手卡是否存在满足条件的怪兽且场上存在空位
function c20474741.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c20474741.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，指定将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤操作
function c20474741.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否有空位，若无则取消效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c20474741.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
