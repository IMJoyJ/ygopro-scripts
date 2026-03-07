--マリスボラス・スプーン
-- 效果：
-- 这张卡在场上表侧表示存在的场合「食恶餐匙鬼」以外的名字带有「食恶」的怪兽在自己场上召唤·特殊召唤时，可以从自己墓地选择1只恶魔族·2星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「食恶餐匙鬼」的效果1回合只能使用1次。
function c35307484.initial_effect(c)
	-- 效果原文内容：这张卡在场上表侧表示存在的场合「食恶餐匙鬼」以外的名字带有「食恶」的怪兽在自己场上召唤·特殊召唤时，可以从自己墓地选择1只恶魔族·2星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「食恶餐匙鬼」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35307484,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,35307484)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c35307484.condition)
	e1:SetTarget(c35307484.target)
	e1:SetOperation(c35307484.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤场上己方表侧表示存在的、名字带有「食恶」且不是食恶餐匙鬼的怪兽
function c35307484.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x8b) and not c:IsCode(35307484)
end
-- 规则层面作用：判断是否有满足条件的己方怪兽被召唤或特殊召唤
function c35307484.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c35307484.cfilter,1,nil,tp)
end
-- 规则层面作用：过滤墓地里等级为2、种族为恶魔族且可以特殊召唤的怪兽
function c35307484.spfilter(c,e,tp)
	return c:IsLevel(2) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果目标为己方墓地满足条件的怪兽
function c35307484.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c35307484.spfilter(chkc,e,tp) end
	-- 规则层面作用：判断己方场上是否有空位可以特殊召唤怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断己方墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c35307484.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c35307484.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：处理效果的发动，包括特殊召唤怪兽并使其效果无效
function c35307484.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断己方场上是否还有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否仍然存在于场上并执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 规则层面作用：完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
