--竜の転生
-- 效果：
-- ①：以自己场上1只龙族怪兽为对象才能发动。那只自己的龙族怪兽除外，从自己的手卡·墓地选1只龙族怪兽特殊召唤。
function c20638610.initial_effect(c)
	-- ①：以自己场上1只龙族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c20638610.target)
	e1:SetOperation(c20638610.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为正面表示的龙族且可以除外的怪兽。
function c20638610.rmfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToRemove()
end
-- 过滤函数，用于判断是否为龙族且可以特殊召唤的怪兽。
function c20638610.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动条件判断，检查是否满足除外和特殊召唤的条件。
function c20638610.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20638610.rmfilter(chkc) end
	-- 检查玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查玩家场上是否存在满足条件的龙族怪兽作为除外对象。
		and Duel.IsExistingTarget(c20638610.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家手牌或墓地是否存在满足条件的龙族怪兽用于特殊召唤。
		and Duel.IsExistingMatchingCard(c20638610.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向玩家提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的龙族怪兽作为除外对象。
	local g=Duel.SelectTarget(tp,c20638610.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息，记录将要除外的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置效果操作信息，记录将要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果的处理函数，执行除外和特殊召唤的操作。
function c20638610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否为正面表示、属于玩家控制、且与当前效果相关联，然后将其除外。
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家提示选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从玩家手牌或墓地选择满足条件的龙族怪兽用于特殊召唤。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20638610.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的龙族怪兽特殊召唤到玩家场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
