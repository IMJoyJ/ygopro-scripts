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
-- 效果发动条件：自己场上没有怪兽存在
function c47482043.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 检索满足条件的墓地「古代的机械」怪兽
function c47482043.spfilter(c,e,tp)
	return c:IsSetCard(0x7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择效果对象：从自己墓地选择1只满足条件的「古代的机械」怪兽
function c47482043.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47482043.spfilter(chkc,e,tp) end
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在满足条件的「古代的机械」怪兽
		and Duel.IsExistingTarget(c47482043.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择并设置效果对象为1只满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c47482043.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果：将选中的怪兽特殊召唤，并使其攻击力上升200
function c47482043.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且成功执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- ②：这个效果特殊召唤的怪兽的攻击力上升200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
