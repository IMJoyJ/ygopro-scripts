--新世壊
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，和那只怪兽是原本的种族·属性不同并持有比那只怪兽的原本等级低的等级的1只怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c21570001.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，和那只怪兽是原本的种族·属性不同并持有比那只怪兽的原本等级低的等级的1只怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21570001+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c21570001.target)
	e1:SetOperation(c21570001.activate)
	c:RegisterEffect(e1)
end
-- 满足条件的怪兽必须表侧表示、原本等级大于1、场上存在可用怪兽区、且卡组存在符合条件的怪兽。
function c21570001.filter(c,e,tp)
	-- 满足条件的怪兽必须表侧表示、原本等级大于1、场上存在可用怪兽区。
	return c:IsFaceup() and c:GetOriginalLevel()>1 and Duel.GetMZoneCount(tp,c)>0
		-- 满足条件的怪兽必须卡组存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c21570001.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 满足条件的怪兽必须等级低于目标怪兽原本等级、种族与目标怪兽原本种族不同、属性与目标怪兽原本属性不同、可以守备表示特殊召唤。
function c21570001.filter2(c,e,tp,tc)
	return c:IsLevelBelow(tc:GetOriginalLevel()-1)
		and not c:IsRace(tc:GetOriginalRace())
		and not c:IsAttribute(tc:GetOriginalAttribute())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 选择满足条件的场上怪兽作为效果对象。
function c21570001.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21570001.filter(chkc,e,tp) end
	-- 检查是否满足发动条件，即场上存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21570001.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的场上怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c21570001.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息，确定要特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，判断目标怪兽是否有效、是否成功破坏、场上是否有空位。
function c21570001.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效、是否成功破坏、场上是否有空位。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择满足条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,c21570001.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		if #g>0 then
			local sc=g:GetFirst()
			-- 尝试特殊召唤该怪兽。
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 使特殊召唤的怪兽效果无效。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 使特殊召唤的怪兽效果无效。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
			-- 完成特殊召唤流程。
			Duel.SpecialSummonComplete()
		end
	end
end
