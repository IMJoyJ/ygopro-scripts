--古代の機械蘇生
-- 效果：
-- ①：「古代的机械苏生」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，自己场上没有怪兽存在的场合，以自己墓地1只「古代的机械」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力上升200。
function c47482043.initial_effect(c)
	c:SetUniqueOnField(1,0,47482043)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上没有怪兽存在的场合，以自己墓地1只「古代的机械」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力上升200。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c47482043.spcon)
	e2:SetTarget(c47482043.sptg)
	e2:SetOperation(c47482043.spop)
	c:RegisterEffect(e2)
end
-- ②效果的发动条件：检查自己场上（主要怪兽区）没有怪兽存在。
function c47482043.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上主要怪兽区的怪兽数量是否为0，用于满足「自己场上没有怪兽存在」的发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 墓地中「古代的机械」怪兽的筛选函数：要求卡名属于「古代的机械」字段，且能被当前效果特殊召唤。
function c47482043.spfilter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标选择处理：确认自己场上有空位且墓地存在符合条件的「古代的机械」怪兽，然后令玩家选择1只作为对象。
function c47482043.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47482043.spfilter(chkc,e,tp) end
	-- 效果发动时检查自己场上是否存在空余的主要怪兽区域，确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在1只以上满足筛选条件的「古代的机械」怪兽，且该怪兽能成为效果对象。
		and Duel.IsExistingTarget(c47482043.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作玩家显示「请选择要特殊召唤的卡」的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 令玩家从自己墓地选择1只符合条件的「古代的机械」怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c47482043.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤，用于后续连锁判定与效果处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果实际处理：将对象怪兽特殊召唤，并让其攻击力上升200，最后完成特殊召唤流程。
function c47482043.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联后，以表侧攻击表示将其特殊召唤（特殊召唤步骤）；若特殊召唤成功则继续附加攻击力上升效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力上升200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤流程，触发特殊召唤成功时的各种时点。
	Duel.SpecialSummonComplete()
end
