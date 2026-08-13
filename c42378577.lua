--ペンデュラム・スイッチ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。
-- ②：以自己的怪兽区域1只灵摆怪兽为对象才能发动。那只灵摆怪兽在自己的灵摆区域放置。
function c42378577.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42378577,0))  --"灵摆区域怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,42378577)
	e2:SetTarget(c42378577.sptg)
	e2:SetOperation(c42378577.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：以自己的怪兽区域1只灵摆怪兽为对象才能发动。那只灵摆怪兽在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42378577,1))  --"灵摆怪兽在灵摆区域放置"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,42378577)
	e3:SetTarget(c42378577.pentg)
	e3:SetOperation(c42378577.penop)
	c:RegisterEffect(e3)
end
-- spfilter为特殊召唤的筛选函数：判断卡片c是否能够被效果e由玩家tp特殊召唤（不额外指定召唤方式，检查常规召唤条件和苏生限制），用于选出可被①效果特殊召唤的灵摆区卡片。
function c42378577.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- sptg是①效果的发动条件与取对象判定：chkc用于确认自动选择的对象时必须位于我方灵摆区且满足特殊召唤条件；chk==0时确认发动时机，要求我方主怪兽区有空位且存在至少1张符合条件的灵摆区卡片作为对象。
function c42378577.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c42378577.spfilter(chkc,e,tp) end
	-- 发动条件之一：我方主要怪兽区存在可用空格，以便特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：我方灵摆区存在至少1张满足spfilter条件且能成为对象的卡片。
		and Duel.IsExistingTarget(c42378577.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 给玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从我方灵摆区选择1张满足spfilter的卡片，将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c42378577.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁处理将进行特殊召唤，对象为已选择的卡片g，数量为1；供其他卡检测此次效果是否包含特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- spop是①效果的处理：取得对象卡，若对象仍与该效果关联，则将其表侧表示特殊召唤到自己的怪兽区域。
function c42378577.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个（唯一一个）效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示（POS_FACEUP）特殊召唤到tp的怪兽区域；sumtype=0表示不适用特殊召唤方式限制，nocheck/nolimit为false表示仍需正常处理召唤条件和苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- filter为②效果的对象筛选函数：判断卡片是否表侧表示且为灵摆怪兽，用于选择我方怪兽区中的灵摆怪兽。
function c42378577.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- pentg是②效果的发动条件与取对象判定：chkc用于确认自动选择的对象必须位于我方怪兽区且为表侧灵摆怪兽；chk==0时确认发动时机，要求我方灵摆区至少有一个空位且存在至少1只符合条件的灵摆怪兽作为对象。
function c42378577.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42378577.filter(chkc) end
	-- 发动条件之一：我方灵摆区的左侧或右侧至少有一个空位，以便放置灵摆怪兽。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 发动条件之二：我方怪兽区存在至少1只表侧表示且为灵摆怪兽的卡片，可以作为对象。
		and Duel.IsExistingTarget(c42378577.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示选择提示，提示内容为“请选择要放置到灵摆区域的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(42378577,2))  --"请选择要放置到灵摆区域的卡"
	-- 让我方从我方怪兽区选择1只满足filter的灵摆怪兽，将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c42378577.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- penop是②效果的处理：取得对象卡，若对象仍与该效果关联且保持表侧表示，则将其移动到自己的灵摆区域。
function c42378577.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象卡移动到我方灵摆区域，以表侧表示放置，并立刻适用该卡的灵摆效果。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
