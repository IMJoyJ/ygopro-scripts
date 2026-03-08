--御巫の契り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「御巫」怪兽特殊召唤。那之后，可以把1张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c42705243.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,42705243+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c42705243.target)
	e1:SetOperation(c42705243.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「御巫」怪兽
function c42705243.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：检查是否满足发动条件
function c42705243.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查手卡或卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c42705243.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 检索满足条件的装备魔法卡
function c42705243.eqfilter(c,tp,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and c:CheckEquipTarget(ec)
end
-- 效果作用：处理特殊召唤和装备效果
function c42705243.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择要特殊召唤的怪兽
	local tc=Duel.SelectMatchingCard(tp,c42705243.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 效果作用：执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文内容：①：从手卡·卡组把1只「御巫」怪兽特殊召唤。那之后，可以把1张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- 效果作用：完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 效果作用：检查装备区域是否有空位
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 效果作用：检查手卡或墓地是否存在满足条件的装备魔法卡
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c42705243.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp,tc)
			-- 效果作用：询问是否装备装备魔法卡
			and Duel.SelectYesNo(tp,aux.Stringid(42705243,0)) then  --"是否选装备魔法卡装备？"
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：提示选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 效果作用：选择要装备的装备魔法卡
			local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c42705243.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp,tc)
			local eqc=eqg:GetFirst()
			-- 效果作用：执行装备操作
			Duel.Equip(tp,eqc,tc)
		end
	end
end
