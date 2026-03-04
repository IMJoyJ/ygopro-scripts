--マタタビ仙狸
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡解放，以「木天蓼仙狸」以外的自己墓地1只2星怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽属性不同的1只2星怪兽从手卡特殊召唤。
function c13382806.initial_effect(c)
	-- ①：把这张卡解放，以「木天蓼仙狸」以外的自己墓地1只2星怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把和这个效果特殊召唤的怪兽属性不同的1只2星怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,13382806)
	e1:SetCost(c13382806.cost)
	e1:SetTarget(c13382806.target)
	e1:SetOperation(c13382806.operation)
	c:RegisterEffect(e1)
end
-- 效果处理时的费用支付函数
function c13382806.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 判断墓地怪兽是否可以特殊召唤的过滤函数
function c13382806.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(2) and not c:IsCode(13382806)
end
-- 效果处理时的选择目标函数
function c13382806.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c13382806.spfilter(chkc,e,tp) end
	-- 检查是否满足发动条件：场上存在可用怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查是否满足发动条件：自己墓地存在符合条件的怪兽
		and Duel.IsExistingTarget(c13382806.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c13382806.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，标明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 判断手卡怪兽是否可以特殊召唤的过滤函数
function c13382806.spfilter2(c,e,tp,attr)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevel(2) and not c:IsAttribute(attr)
end
-- 效果处理时的发动处理函数
function c13382806.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效并将其特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查手卡是否存在属性不同的2星怪兽
		and Duel.IsExistingMatchingCard(c13382806.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,tc:GetAttribute())
		-- 确认是否继续处理后续效果：是否从手卡特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(13382806,0)) then  --"是否从手卡特殊召唤2星怪兽？"
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 向玩家提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择符合条件的手卡怪兽
		local sg=Duel.SelectMatchingCard(tp,c13382806.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetAttribute())
		-- 将选择的手卡怪兽特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
