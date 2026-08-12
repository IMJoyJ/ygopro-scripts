--強化蘇生
-- 效果：
-- ①：以自己墓地1只4星以下的怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。只要这张卡在魔法与陷阱区域存在，那只怪兽的等级上升1星，攻击力·守备力上升100。那只怪兽破坏时这张卡破坏。
function c84298614.initial_effect(c)
	-- ①：以自己墓地1只4星以下的怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c84298614.target)
	e1:SetOperation(c84298614.operation)
	c:RegisterEffect(e1)
	-- 那只怪兽破坏时这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c84298614.descon)
	e2:SetOperation(c84298614.desop)
	c:RegisterEffect(e2)
	-- 只要这张卡在魔法与陷阱区域存在，那只怪兽的等级上升1星，攻击力·守备力上升100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(100)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_UPDATE_LEVEL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end
-- 过滤自己墓地等级4以下且可以特殊召唤的怪兽
function c84298614.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的对象选择与可行性检查
function c84298614.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84298614.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的、可以作为效果对象的怪兽
		and Duel.IsExistingTarget(c84298614.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84298614.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽特殊召唤，并与这张卡建立对象关联
function c84298614.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽以表侧表示特殊召唤到自己场上（分解步骤）
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
-- 检查被这张卡作为对象的怪兽是否因破坏而离场
function c84298614.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 将这张卡破坏
function c84298614.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将这张卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
