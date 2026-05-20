--死者蘇生
-- 效果：
-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c83764718.initial_effect(c)
	-- ①：以自己或对方的墓地1只怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c83764718.target)
	e1:SetOperation(c83764718.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：可以在当前场上特殊召唤的怪兽
function c83764718.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检查
function c83764718.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c83764718.filter(chkc,e,tp) end
	-- 检查发动玩家的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只可以特殊召唤的怪兽作为合法对象
		and Duel.IsExistingTarget(c83764718.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择双方墓地中1只满足特殊召唤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83764718.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的执行函数
function c83764718.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与此效果有关联，且不受王家长眠之谷的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到发动玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
