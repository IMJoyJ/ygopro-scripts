--マリスボラス・ナイフ
-- 效果：
-- 这张卡召唤成功时，可以从自己墓地选择「食恶餐刀鬼」以外的1只名字带有「食恶」的怪兽特殊召唤。
function c98780137.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己墓地选择「食恶餐刀鬼」以外的1只名字带有「食恶」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98780137,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c98780137.target)
	e1:SetOperation(c98780137.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中「食恶餐刀鬼」以外的名字带有「食恶」且可以特殊召唤的怪兽
function c98780137.filter(c,e,tp)
	return not c:IsCode(98780137) and c:IsSetCard(0x8b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象合法性检测与条件判断
function c98780137.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c98780137.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的怪兽作为对象
		and Duel.IsExistingTarget(c98780137.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c98780137.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c98780137.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
