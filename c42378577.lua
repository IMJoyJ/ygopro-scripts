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
	-- ①：以自己的灵摆区域1张卡为对象才能发动。那张卡特殊召唤。
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
	-- ②：以自己的怪兽区域1只灵摆怪兽为对象才能发动。那只灵摆怪兽在自己的灵摆区域放置。
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
-- 检索满足特殊召唤条件的灵摆区域卡片
function c42378577.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件
function c42378577.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c42378577.spfilter(chkc,e,tp) end
	-- 判断灵摆区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断灵摆区域是否有满足条件的卡片
		and Duel.IsExistingTarget(c42378577.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的灵摆区域卡片作为对象
	local g=Duel.SelectTarget(tp,c42378577.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理①效果的发动
function c42378577.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断目标是否为灵摆怪兽
function c42378577.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 判断是否满足②效果的发动条件
function c42378577.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42378577.filter(chkc) end
	-- 判断灵摆区域是否有空位
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 判断怪兽区域是否有满足条件的灵摆怪兽
		and Duel.IsExistingTarget(c42378577.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要放置到灵摆区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(42378577,2))  --"请选择要放置到灵摆区域的卡"
	-- 选择满足条件的灵摆怪兽作为对象
	local g=Duel.SelectTarget(tp,c42378577.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理②效果的发动
function c42378577.penop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标灵摆怪兽移动到灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
