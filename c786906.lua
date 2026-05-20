--逢魔ノ刻
-- 效果：
-- ①：以自己或者对方的墓地1只不能通常召唤的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
function c786906.initial_effect(c)
	-- ①：以自己或者对方的墓地1只不能通常召唤的怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c786906.target)
	e1:SetOperation(c786906.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：不能通常召唤且可以被特殊召唤的怪兽
function c786906.filter(c,e,tp)
	return not c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测：支持作为效果对象时的合法性检查，以及发动时对怪兽区域空位和墓地中合法对象的检测
function c786906.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c786906.filter(chkc,e,tp) end
	-- 检查发动玩家的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己或对方的墓地是否存在至少1只满足过滤条件的可选择对象
		and Duel.IsExistingTarget(c786906.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己或对方墓地1只满足过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c786906.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1个对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取选择的对象，若该对象仍与效果有关联，则将其在发动玩家的场上特殊召唤
function c786906.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动玩家的场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
