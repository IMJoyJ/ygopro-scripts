--蒼焔の煉獄
-- 效果：
-- ①：从手卡把1只「狱火机」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
function c57047293.initial_effect(c)
	-- ①：从手卡把1只「狱火机」怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c57047293.target)
	e1:SetOperation(c57047293.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可以无视召唤条件特殊召唤的「狱火机」怪兽
function c57047293.filter(c,e,tp)
	return c:IsSetCard(0xbb) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动的目标检查，确认怪兽区域有空位且手卡有可特殊召唤的怪兽
function c57047293.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的「狱火机」怪兽
		and Duel.IsExistingMatchingCard(c57047293.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，声明将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行，从手卡特殊召唤怪兽并将其效果无效化
function c57047293.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时怪兽区域已无空位，则不进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「狱火机」怪兽
	local g=Duel.SelectMatchingCard(tp,c57047293.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将该怪兽无视召唤条件以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
