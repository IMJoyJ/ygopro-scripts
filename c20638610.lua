--竜の転生
-- 效果：
-- ①：以自己场上1只龙族怪兽为对象才能发动。那只自己的龙族怪兽除外，从自己的手卡·墓地选1只龙族怪兽特殊召唤。
function c20638610.initial_effect(c)
	-- ①：以自己场上1只龙族怪兽为对象才能发动。那只自己的龙族怪兽除外，从自己的手卡·墓地选1只龙族怪兽特殊召唤。
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
-- 过滤函数：判断怪兽是否为表侧表示且龙族且能被除外，用于选择自己场上的龙族怪兽作为发动对象。
function c20638610.rmfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToRemove()
end
-- 过滤函数：判断手卡·墓地的龙族怪兽是否满足被当前效果特殊召唤的合法条件（不忽略召唤条件与苏生限制）。
function c20638610.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与合法性检查函数：需要选择自己场上1只表侧表示且能除外的龙族怪兽为对象，并确认手卡·墓地存在可特殊召唤的龙族怪兽；同时登记除外与特殊召唤的操作信息。
function c20638610.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20638610.rmfilter(chkc) end
	-- 检查除外后是否有足够的怪兽区域使用（不要求当前有空格，因为先除外可能腾出格子）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己场上是否存在至少1只表侧表示且能除外的龙族怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c20638610.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的手卡·墓地是否存在至少1只可被当前效果特殊召唤的龙族怪兽。
		and Duel.IsExistingMatchingCard(c20638610.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足条件的龙族怪兽，并将其设为该连锁的对象。
	local g=Duel.SelectTarget(tp,c20638610.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记该连锁将执行除外操作，对象为所选怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 登记该连锁将执行特殊召唤操作，预计从手卡·墓地特殊召唤1只龙族怪兽（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理函数：先取得对象怪兽，确认其仍合法后将其表侧除外；若除外成功且场上仍有可用区域，则从手卡·墓地选择1只龙族怪兽特殊召唤。
function c20638610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择作为对象的龙族怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在自己场上表侧表示且与效果关联，并执行除外；若除外成功则继续处理。
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 除外后若自己场上没有可用的怪兽区域，则不进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 弹出选择提示，让玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只满足条件的龙族怪兽（受王家长眠之谷影响的卡不能选择）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20638610.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的龙族怪兽表侧表示特殊召唤到自己场上（需满足召唤条件与苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
