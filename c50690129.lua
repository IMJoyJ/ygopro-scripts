--キャシー・イヴL2
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡存在的场合，以自己场上1只3星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。
function c50690129.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡存在的场合，以自己场上1只3星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50690129,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50690129)
	e1:SetTarget(c50690129.target)
	e1:SetOperation(c50690129.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足条件的对象：必须是表侧表示且等级在3星以上的怪兽。
function c50690129.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(3)
end
-- 效果发动的目标判定与处理函数：确认对象为我方场上的表侧3星以上怪兽，并检查是否有空位以及自身能否特殊召唤；在发动时选定对象并登记特殊召唤信息。
function c50690129.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50690129.filter(chkc) end
	local c=e:GetHandler()
	-- 检查我方场上是否存在至少1只满足条件的表侧3星以上怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c50690129.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认我方主要怪兽区有空位，且手牌中的这张卡可以被效果特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 让玩家进行对象选择时显示“请选择表侧表示的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从我方场上选择1只满足条件的表侧3星以上怪兽作为效果对象。
	Duel.SelectTarget(tp,c50690129.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向系统登记本次连锁中特殊召唤这张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理阶段：获取对象，若对象仍合法则使其等级下降2星，然后将这张卡特殊召唤。
function c50690129.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<3 then return end
	local c=e:GetHandler()
	-- 那只怪兽的等级下降2星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-2)
	tc:RegisterEffect(e1)
	if not tc:IsImmuneToEffect(e1) and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者场上，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
