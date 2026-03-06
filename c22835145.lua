--BF－極北のブリザード
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤成功时，以自己墓地1只4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c22835145.initial_effect(c)
	-- 效果原文：这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 规则层面操作：设置该卡无法特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡召唤成功时，以自己墓地1只4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22835145,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c22835145.target)
	e2:SetOperation(c22835145.operation)
	c:RegisterEffect(e2)
end
-- 规则层面操作：筛选满足条件的墓地黑羽怪兽（4星以下且可特殊召唤）。
function c22835145.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面操作：判断是否满足发动条件（场上是否有空位且墓地是否存在符合条件的怪兽）。
function c22835145.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22835145.filter(chkc,e,tp) end
	-- 规则层面操作：判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断墓地是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c22835145.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：选择目标怪兽。
	local g=Duel.SelectTarget(tp,c22835145.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面操作：设置连锁操作信息，表明将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面操作：执行特殊召唤操作。
function c22835145.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断场上是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽以守备表示特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
