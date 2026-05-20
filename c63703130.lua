--O－オーバーソウル
-- 效果：
-- ①：以自己墓地1只「元素英雄」通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c63703130.initial_effect(c)
	-- ①：以自己墓地1只「元素英雄」通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63703130.target)
	e1:SetOperation(c63703130.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以特殊召唤的「元素英雄」通常怪兽
function c63703130.filter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查（判断自己场上是否有空位，以及墓地是否存在符合条件的对象）
function c63703130.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c63703130.filter(chkc,e,tp) end
	-- 检查发动时自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只符合条件的「元素英雄」通常怪兽
		and Duel.IsExistingTarget(c63703130.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「元素英雄」通常怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c63703130.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含将选中的1张卡特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数，将选中的对象怪兽特殊召唤
function c63703130.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
