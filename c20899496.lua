--天龍雪獄
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方墓地1只怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。那之后，可以从自己以及对方场上把种族相同的怪兽各1只除外。
function c20899496.initial_effect(c)
	-- 效果原文内容：①：以对方墓地1只怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。那之后，可以从自己以及对方场上把种族相同的怪兽各1只除外。
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
-- 效果作用：判断目标怪兽是否可以被特殊召唤
function c20899496.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果目标为对方墓地满足条件的怪兽
function c20899496.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c20899496.spfilter(chkc,e,tp) end
	-- 效果作用：判断自己场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断对方墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c20899496.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c20899496.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 效果作用：设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 效果作用：设置操作信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,PLAYER_ALL,LOCATION_MZONE)
end
-- 效果作用：判断场上怪兽是否可以被除外
function c20899496.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果作用：判断所选怪兽组是否满足种族和控制者条件
function c20899496.fselect(g)
	return g:GetClassCount(Card.GetControler)==g:GetCount() and g:IsExists(c20899496.fcheck,1,nil,g)
end
-- 效果作用：判断所选怪兽组中是否存在相同种族的怪兽
function c20899496.fcheck(c,g)
	return g:IsExists(Card.IsRace,1,c,c:GetRace())
end
-- 效果原文内容：①：以对方墓地1只怪兽为对象才能发动。那只怪兽效果无效在自己场上特殊召唤。那之后，可以从自己以及对方场上把种族相同的怪兽各1只除外。
function c20899496.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	local res=false
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将目标怪兽特殊召唤
		res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		if res then
			-- 效果原文内容：那只怪兽效果无效在自己场上特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果原文内容：那只怪兽效果无效在自己场上特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 效果作用：完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
	if res then
		-- 效果作用：获取场上所有可以除外的怪兽
		local g=Duel.GetMatchingGroup(c20899496.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 效果作用：判断是否满足除外条件并询问玩家是否除外
		if g:CheckSubGroup(c20899496.fselect,2,2) and Duel.SelectYesNo(tp,aux.Stringid(20899496,0)) then  --"是否选怪兽除外？"
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:SelectSubGroup(tp,c20899496.fselect,false,2,2)
			-- 效果作用：显示所选卡被选为对象的动画
			Duel.HintSelection(sg)
			-- 效果作用：将所选怪兽除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
