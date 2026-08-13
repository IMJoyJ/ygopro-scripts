--トライデント・ウォリアー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把1只3星怪兽特殊召唤。
function c20474741.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把1只3星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20474741,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c20474741.sumtg)
	e2:SetOperation(c20474741.sumop)
	c:RegisterEffect(e2)
end
-- 筛选手牌中等级为3且可以被当前效果特殊召唤的怪兽。
function c20474741.filter(c,e,tp)
	return c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件的判定：自己主要怪兽区有空位，且手牌中存在至少1只等级为3并可特殊召唤的怪兽。
function c20474741.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否还有空位，作为效果可发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只等级为3且可被特殊召唤的怪兽（存在则效果可发动）。
		and Duel.IsExistingMatchingCard(c20474741.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次特殊召唤的操作信息：从手牌特殊召唤1只怪兽（用于让其他卡正确响应）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若自己主要怪兽区有空位，则从手牌选择1只3星怪兽特殊召唤。
function c20474741.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区有空位，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，供其选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1张等级为3且可特殊召唤的怪兽（选1张）。
	local g=Duel.SelectMatchingCard(tp,c20474741.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
