--死神の呼び声
-- 效果：
-- 从自己墓地有怪兽特殊召唤时才能发动。选择自己墓地存在的1只「苏帕伊」或者「赤蚁」特殊召唤。
function c45133463.initial_effect(c)
	-- 创建效果，设置效果分类为特殊召唤，设置效果属性为取对象，设置效果类型为发动，设置效果时点为特殊召唤成功，设置效果发动条件、目标和效果处理函数
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
-- 过滤函数，用于判断卡片是否从墓地离开且控制者为玩家
function c45133463.cfiltetr(c,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 效果发动条件，判断是否有从墓地离开的怪兽
function c45133463.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c45133463.cfiltetr,1,nil,tp)
end
-- 过滤函数，用于判断卡片是否为「苏帕伊」或「赤蚁」且可以特殊召唤
function c45133463.filter(c,e,tp)
	return c:IsCode(78552773,78275321) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，判断是否可以选取满足条件的卡片作为目标
function c45133463.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45133463.filter(chkc,e,tp) end
	-- 判断玩家场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在满足条件的卡片
		and Duel.IsExistingTarget(c45133463.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡片作为效果目标
	local g=Duel.SelectTarget(tp,c45133463.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡片数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的卡片特殊召唤
function c45133463.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
