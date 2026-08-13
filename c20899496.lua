--天龍雪獄
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。那之后，可以从自己以及对方场上把种族相同的怪兽各1只除外。
function c20899496.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方墓地1只怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。那之后，可以从自己以及对方场上把种族相同的怪兽各1只除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,20899496+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c20899496.target)
	e1:SetOperation(c20899496.activate)
	c:RegisterEffect(e1)
end
-- 特殊召唤筛选函数：判断怪兽是否满足被当前效果特殊召唤的条件（不无视召唤条件与苏生限制）。
function c20899496.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动条件的判断与取对象：若已在连锁中指定对象，则校验对象位于对方墓地且可特殊召唤；若无对象，则检查己方怪兽区有空位且对方墓地存在可特殊召唤的怪兽。
function c20899496.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c20899496.spfilter(chkc,e,tp) end
	-- 确认自己主要怪兽区有空余区域，用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认对方墓地存在至少1只满足特殊召唤条件的怪兽，作为发动效果的对象候选。
		and Duel.IsExistingTarget(c20899496.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求其从对方墓地选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从对方墓地选择1只可特殊召唤的怪兽作为效果对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c20899496.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置本次特殊召唤的操作信息：已确定将对象怪兽特殊召唤，数量为1，控制者为己方。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置除外效果的操作信息：后续可能除外双方场上的怪兽，具体对象和数量在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_ALL,LOCATION_MZONE)
end
-- 除外筛选函数：选择表侧表示且可以被除外的怪兽。
function c20899496.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 选择子组的条件：选出的2张怪兽必须分属双方（控制者不同），且其中存在种族相同的组合。
function c20899496.fselect(g)
	return g:GetClassCount(Card.GetControler)==g:GetCount() and g:IsExists(c20899496.fcheck,1,nil,g)
end
-- 辅助判断：检查给定怪兽组中是否存在与指定怪兽相同种族的另一只怪兽。
function c20899496.fcheck(c,g)
	return g:IsExists(Card.IsRace,1,c,c:GetRace())
end
-- 效果处理流程：将对象怪兽特殊召唤到己方场上并赋予其效果无效化，若成功则征询玩家是否除外双方场上各1只同种族怪兽；选择后将其除外。
function c20899496.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽（对方墓地的1只怪兽）。
	local tc=Duel.GetFirstTarget()
	local res=false
	if tc:IsRelateToEffect(e) then
		-- 先将对象怪兽以表侧表示特殊召唤到己方场上（作为连锁处理的一部分，尚未完成特殊召唤）。
		res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		if res then
			-- 那只怪兽效果无效在自己场上特殊召唤（使那只怪兽的效果无效）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 那只怪兽效果无效（使其效果无效化的效果持续适用）。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤处理，确认所有用SpecialSummonStep召唤的怪兽都正式上场。
		Duel.SpecialSummonComplete()
	end
	if res then
		-- 获取双方场上所有表侧表示且可以被除外的怪兽，作为后续选择除外的候选集合。
		local g=Duel.GetMatchingGroup(c20899496.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 判断候选集合中是否存在满足条件的2张怪兽（双方各1只且种族相同），并征询玩家是否发动除外效果。
		if g:CheckSubGroup(c20899496.fselect,2,2) and Duel.SelectYesNo(tp,aux.Stringid(20899496,0)) then  --"是否选怪兽除外？"
			-- 中断当前效果链，使后续的除外处理与之前的特殊召唤不视为同时处理，避免错时点。
			Duel.BreakEffect()
			-- 向玩家显示选择提示，要求其选择要除外的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:SelectSubGroup(tp,c20899496.fselect,false,2,2)
			-- 显示被选中的除外对象动画，并将其标记为这次效果的对象。
			Duel.HintSelection(sg)
			-- 将选中的2张怪兽以表侧表示除外，处理原因为效果。
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
