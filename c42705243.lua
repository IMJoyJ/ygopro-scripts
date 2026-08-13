--御巫の契り
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡·卡组把1只「御巫」怪兽特殊召唤。那之后，可以把1张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c42705243.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡·卡组把1只「御巫」怪兽特殊召唤。那之后，可以把1张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
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
-- 特殊召唤筛选条件：限定「御巫」字段怪兽，并检测该怪兽能否被当前效果以通常方式特殊召唤（不无视召唤条件、不无视苏生限制）。
function c42705243.spfilter(c,e,tp)
	return c:IsSetCard(0x18d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的合法判定：该效果在判定时要求自己主要怪兽区有空位，且手牌·卡组中存在至少1只满足特殊召唤条件的「御巫」怪兽。
function c42705243.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件之一，检查自己场上主要怪兽区是否存在空位（用于放置要特殊召唤的怪兽）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 作为发动条件之二，从自己的手牌·卡组检查是否存在至少1只满足spfilter条件的「御巫」怪兽。
		and Duel.IsExistingMatchingCard(c42705243.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向连锁系统登记本次操作信息：效果将进行特殊召唤，处理时从自己手牌·卡组选1只怪兽特殊召唤，供其他卡（如星尘龙、王家长眠之谷等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 装备魔法卡筛选条件：是装备魔法卡、该装备卡在自己场上不违反同名卡唯一性限制、未被禁止使用、并且能够装备给已特殊召唤出的那只「御巫」怪兽。
function c42705243.eqfilter(c,tp,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and c:CheckEquipTarget(ec)
end
-- 效果处理：若怪兽区有空位，则从手牌·卡组选择1只「御巫」怪兽进行特殊召唤，给那只怪兽附加“离场时除外”的效果；之后可询问是否从手牌·墓地选择1张能装备的装备魔法卡装备给它。
function c42705243.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认主要怪兽区有空位；若没有空位则直接结束处理，不进行后续特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示框，提示玩家选择要特殊召唤的卡片（提示类型为特殊召唤选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的手牌·卡组中选出1只满足spfilter条件的「御巫」怪兽作为要特殊召唤的卡。
	local tc=Duel.SelectMatchingCard(tp,c42705243.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	-- 尝试将选中的怪兽以表侧表示特殊召唤（使用分步特殊召唤流程），若特殊召唤成功则进入后续处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那之后，可以把1张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备。这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- 完成整个分步特殊召唤流程，正式把Step中特殊召唤的怪兽放置到场上，并触发召唤成功等时点。
		Duel.SpecialSummonComplete()
		-- 检查自己魔陷区是否有空位；装备魔法要装备时也需要占用魔陷区，若没有空位则不能进行装备。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			-- 从手牌·墓地检查是否存在可装备的装备魔法卡；同时滤除受王家长眠之谷影响而不能从墓地特殊召唤/移动的卡（此处实际是墓地装备卡移动限制的过滤）。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c42705243.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp,tc)
			-- 弹出是否选择装备魔法卡的询问，只有玩家选择“是”时才继续执行装备处理。
			and Duel.SelectYesNo(tp,aux.Stringid(42705243,0)) then  --"是否选装备魔法卡装备？"
			-- 中断当前连锁的效果处理，使后续‘装备装备魔法’的处理与前面的特殊召唤处理分属不同时点，避免错过时点或产生同时处理。
			Duel.BreakEffect()
			-- 弹出选择提示框，提示玩家选择要装备的装备魔法卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 玩家从自己的手牌·墓地中选择1张满足eqfilter且不受王家长眠之谷影响的装备魔法卡。
			local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c42705243.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp,tc)
			local eqc=eqg:GetFirst()
			-- 将选中的装备魔法卡装备给此前特殊召唤的「御巫」怪兽。
			Duel.Equip(tp,eqc,tc)
		end
	end
end
