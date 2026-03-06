--星屑の残光
-- 效果：
-- ①：以自己墓地1只「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
function c27196937.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c27196937.target)
	e1:SetOperation(c27196937.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤器，用于筛选满足条件的「星尘」怪兽（可特殊召唤）
function c27196937.filter(c,e,tp)
	return c:IsSetCard(0xa3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的目标选择条件，确保目标为己方墓地中的「星尘」怪兽
function c27196937.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c27196937.filter(chkc,e,tp) end
	-- 规则层面作用：检查己方场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：确认己方墓地中是否存在符合条件的「星尘」怪兽作为目标
		and Duel.IsExistingTarget(c27196937.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择符合条件的墓地中的「星尘」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c27196937.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表明本次效果将特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：①：以自己墓地1只「星尘」怪兽为对象才能发动。那只怪兽特殊召唤。
function c27196937.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中被指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
