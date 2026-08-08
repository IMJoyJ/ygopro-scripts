--死神の呼び声
-- 效果：
-- 从自己墓地有怪兽特殊召唤时才能发动。选择自己墓地存在的1只「苏帕伊」或者「赤蚁」特殊召唤。
function c45133463.initial_effect(c)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c45133463.condition)
	e1:SetTarget(c45133463.target)
	e1:SetOperation(c45133463.activate)
	c:RegisterEffect(e1)
end
-- 执行对应的效果条件检查或辅助函数处理
function c45133463.cfiltetr(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 执行对应的效果条件检查或辅助函数处理
function c45133463.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c45133463.cfiltetr,1,nil,tp)
end
-- 执行对应的效果条件检查或辅助函数处理
function c45133463.filter(c,e,tp)
	return c:IsCode(78552773,78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行对应的效果条件检查或辅助函数处理
function c45133463.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45133463.filter(chkc,e,tp) end
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 执行对应的效果条件检查或辅助函数处理
		and Duel.IsExistingTarget(c45133463.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	local g=Duel.SelectTarget(tp,c45133463.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行对应的效果条件检查或辅助函数处理
function c45133463.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
