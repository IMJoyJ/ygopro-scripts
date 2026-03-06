--横綱犬
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己的手卡·墓地选1只调整特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c27750191.initial_effect(c)
	-- 效果原文内容：①：这张卡召唤成功时才能发动。从自己的手卡·墓地选1只调整特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27750191,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27750191.sumtg)
	e1:SetOperation(c27750191.sumop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以特殊召唤的调整怪兽
function c27750191.filter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c27750191.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在满足条件的调整怪兽
		and Duel.IsExistingMatchingCard(c27750191.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡的来源位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，执行特殊召唤和效果无效化操作
function c27750191.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27750191.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 执行特殊召唤步骤
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
