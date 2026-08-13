--真紅眼の鎧旋
-- 效果：
-- 「真红眼的铠旋」的①②的效果1回合各能使用1次。
-- ①：自己场上有「真红眼」怪兽存在的场合，以自己墓地1只通常怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
-- ②：这张卡被对方的效果破坏送去墓地的场合，以自己墓地1只「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
function c39387565.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上有「真红眼」怪兽存在的场合，以自己墓地1只通常怪兽为对象才能把这个效果发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,39387565)
	e2:SetCondition(c39387565.spcon1)
	e2:SetTarget(c39387565.sptg1)
	e2:SetOperation(c39387565.spop1)
	c:RegisterEffect(e2)
	-- ②：这张卡被对方的效果破坏送去墓地的场合，以自己墓地1只「真红眼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,39387566)
	e3:SetCondition(c39387565.spcon2)
	e3:SetTarget(c39387565.sptg2)
	e3:SetOperation(c39387565.spop2)
	c:RegisterEffect(e3)
end
-- 定义过滤器：用于筛选自己场上表侧表示且卡名含有「真红眼」字段的怪兽，作为①效果的发动条件判定。
function c39387565.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end
-- ①效果的发动条件：自己场上存在1只以上表侧表示的「真红眼」怪兽。
function c39387565.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的「真红眼」怪兽，至少1只。
	return Duel.IsExistingMatchingCard(c39387565.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义①效果的对象过滤器：从自己墓地筛选1只通常怪兽，且该怪兽可以被当前效果特殊召唤。
function c39387565.spfilter1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的取对象发动处理：先验证对象候选是否在墓地且属于自己，再检查主怪兽区有空位且墓地存在满足条件的目标。
function c39387565.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39387565.spfilter1(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只能够被特殊召唤的通常怪兽，且该卡可以成为效果对象。
		and Duel.IsExistingTarget(c39387565.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从自己墓地选择1只满足条件的通常怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c39387565.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次操作的信息：将进行1只怪兽的特殊召唤，用于后续连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：将之前选中的通常怪兽特殊召唤到己方场上。
function c39387565.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中该效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡被对方的效果破坏并送去墓地（破坏原因为效果破坏，且对方是效果发动方）。
function c39387565.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT and rp==1-tp
end
-- 定义②效果的对象过滤器：从自己墓地筛选1只「真红眼」怪兽，且该怪兽可以被当前效果特殊召唤。
function c39387565.spfilter2(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的取对象发动处理：先验证对象候选在墓地且属于自己，再检查主怪兽区有空位且墓地存在满足条件的目标。
function c39387565.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39387565.spfilter2(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只能够被特殊召唤的「真红眼」怪兽，且该卡可以成为效果对象。
		and Duel.IsExistingTarget(c39387565.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从自己墓地选择1只满足条件的「真红眼」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c39387565.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次操作的信息：将进行1只怪兽的特殊召唤，用于后续连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将之前选中的「真红眼」怪兽特殊召唤到己方场上。
function c39387565.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中该效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
