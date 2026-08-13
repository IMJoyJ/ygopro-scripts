--星屑の残光
-- 效果：
-- ①：以自己墓地1只「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
function c27196937.initial_effect(c)
	-- ①：以自己墓地1只「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27196937.target)
	e1:SetOperation(c27196937.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择自己墓地中持有「星尘」字段、且能被当前效果特殊召唤的怪兽作为对象。
function c27196937.filter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择与发动条件判定：chkc时验证指定对象是否合法；chk==0时检查发动条件，即场上有空位且墓地存在合法对象。
function c27196937.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c27196937.filter(chkc,e,tp) end
	-- 发动条件检查之一：自己场上主要怪兽区必须存在空闲区域，否则无法特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查之二：自己墓地必须存在至少1只因满足过滤条件且能够成为效果对象的「星尘」怪兽。
		and Duel.IsExistingTarget(c27196937.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示信息，告知玩家正在选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「星尘」怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c27196937.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：向系统声明本连锁将进行特殊召唤，对象为g所指的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上。
function c27196937.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象卡（即之前选择的墓地「星尘」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上，且不无视召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
