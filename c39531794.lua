--ブレインハザード
-- 效果：
-- ①：以除外的1只自己的念动力族怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c39531794.initial_effect(c)
	-- ①：以除外的1只自己的念动力族怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c39531794.target)
	e1:SetOperation(c39531794.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c39531794.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c39531794.descon2)
	e3:SetOperation(c39531794.desop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断候选怪兽必须是表侧表示、念动力族，且能够被当前效果特殊召唤。
function c39531794.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的取对象处理：校验对象必须位于除外区且属于自己，并满足filter条件；同时确认自己主要怪兽区有空位且存在至少1个合法对象。
function c39531794.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c39531794.filter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1张满足条件的自己的念动力族怪兽可以作为对象。
		and Duel.IsExistingTarget(c39531794.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区选择1张符合条件的自己的念动力族怪兽，并将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c39531794.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本效果将进行1只怪兽的特殊召唤，以便其他卡牌进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若这张卡与对象怪兽仍与效果关联，则将对象怪兽特殊召唤到自己的主要怪兽区；若特殊召唤成功，建立这张卡与那只怪兽的永续对象联系。
function c39531794.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 以表侧攻击表示将对象怪兽特殊召唤到自己场上；若特殊召唤失败（返回0）则中止后续处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		c:SetCardTarget(tc)
	end
end
-- 这张卡离场时触发的处理：若其永续对象怪兽仍在怪兽区，则将该对象怪兽破坏。
function c39531794.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏那只对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 触发条件：当这张卡的永续对象怪兽被破坏并离场时（进入连锁的离场事件包含该怪兽且其破坏原因为破坏），条件成立。
function c39531794.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 满足条件时，将这张卡自身破坏。
function c39531794.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏这张卡自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
