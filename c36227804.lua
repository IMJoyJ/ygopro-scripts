--リチュア・ビースト
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的1只4星以下的名字带有「遗式」的怪兽表侧守备表示特殊召唤。
function c36227804.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36227804,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c36227804.target)
	e1:SetOperation(c36227804.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的墓地怪兽（4星以下且名字带有「遗式」且可特殊召唤）
function c36227804.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x3a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标为满足条件的墓地怪兽
function c36227804.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36227804.filter(chkc,e,tp) end
	-- 判断场上是否有空位且墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检索满足条件的墓地怪兽
		Duel.IsExistingTarget(c36227804.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c36227804.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数，将选中的怪兽特殊召唤
function c36227804.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
