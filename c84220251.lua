--蘇生紋章
-- 效果：
-- 选择自己墓地1只名字带有「纹章兽」的怪兽才能发动。选择的怪兽特殊召唤。
function c84220251.initial_effect(c)
	-- 选择自己墓地1只名字带有「纹章兽」的怪兽才能发动。选择的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c84220251.target)
	e1:SetOperation(c84220251.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以特殊召唤的名字带有「纹章兽」的怪兽
function c84220251.filter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检测
function c84220251.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c84220251.filter(chkc,e,tp) end
	-- 检查发动时自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件、可作为效果对象的「纹章兽」怪兽
		and Duel.IsExistingTarget(c84220251.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「纹章兽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84220251.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤该对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数，将选择的对象特殊召唤
function c84220251.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
