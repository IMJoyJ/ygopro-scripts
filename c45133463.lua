--死神の呼び声
-- 效果：
-- 从自己墓地有怪兽特殊召唤时才能发动。选择自己墓地存在的1只「苏帕伊」或者「赤蚁」特殊召唤。
function c45133463.initial_effect(c)
	-- 从自己墓地有怪兽特殊召唤时才能发动。选择自己墓地存在的1只「苏帕伊」或者「赤蚁」特殊召唤。
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
-- 过滤筛选前一次位置在自己墓地且原本类型为怪兽的卡。
function c45133463.cfiltetr(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 效果发动条件：检查特殊召唤的怪兽中是否存在从自己墓地特殊召唤的怪兽。
function c45133463.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c45133463.cfiltetr,1,nil,tp)
end
-- 过滤筛选自己墓地中卡名为「苏帕伊」或「赤蚁」且能特殊召唤的怪兽。
function c45133463.filter(c,e,tp)
	return c:IsCode(78552773,78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的Target逻辑：检查自身怪兽区是否有空位以及墓地是否存在符合条件的「苏帕伊」或「赤蚁」，并取其为对象。
function c45133463.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45133463.filter(chkc,e,tp) end
	-- 检查自身怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以作为对象的「苏帕伊」或「赤蚁」。
		and Duel.IsExistingTarget(c45133463.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置提示信息，指示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只「苏帕伊」或「赤蚁」作为对象。
	local g=Duel.SelectTarget(tp,c45133463.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息为特殊召唤选中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的处理函数：获取选中的目标怪兽，若仍与效果相关则将其表侧表示特殊召唤到场上。
function c45133463.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁选中的第1个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
