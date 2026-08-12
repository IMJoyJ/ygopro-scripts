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
-- 检查场上是否存在真红眼怪兽
function c39387565.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b)
end
-- 效果①的发动条件：自己场上有真红眼怪兽存在
function c39387565.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在真红眼怪兽
	return Duel.IsExistingMatchingCard(c39387565.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的特殊召唤对象过滤器：通常怪兽
function c39387565.spfilter1(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动时选择对象处理：选择墓地的通常怪兽作为对象
function c39387565.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39387565.spfilter1(chkc,e,tp) end
	-- 效果①的发动时确认处理：确认场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果①的发动时确认处理：确认墓地是否存在通常怪兽
		and Duel.IsExistingTarget(c39387565.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地的通常怪兽作为对象
	local g=Duel.SelectTarget(tp,c39387565.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理：将对象怪兽特殊召唤
function c39387565.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：被对方的效果破坏送去墓地
function c39387565.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_DESTROY+REASON_EFFECT)==REASON_DESTROY+REASON_EFFECT and rp==1-tp
end
-- 效果②的特殊召唤对象过滤器：真红眼怪兽
function c39387565.spfilter2(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时选择对象处理：选择墓地的真红眼怪兽作为对象
function c39387565.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39387565.spfilter2(chkc,e,tp) end
	-- 效果②的发动时确认处理：确认场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果②的发动时确认处理：确认墓地是否存在真红眼怪兽
		and Duel.IsExistingTarget(c39387565.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地的真红眼怪兽作为对象
	local g=Duel.SelectTarget(tp,c39387565.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：将对象怪兽特殊召唤
function c39387565.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
