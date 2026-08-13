--新世壊
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，和那只怪兽是原本的种族·属性不同并持有比那只怪兽的原本等级低的等级的1只怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c21570001.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，和那只怪兽是原本的种族·属性不同并持有比那只怪兽的原本等级低的等级的1只怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
-- 定义对象怪兽的筛选条件：对象必须是我方场上表侧表示、原本等级大于1，且其离开后仍有空位可以特殊召唤，同时卡组中存在可特殊召唤的符合条件的怪兽。
function c21570001.filter(c,e,tp)
	-- 检查对象怪兽是否表侧表示、原本等级大于1（因为要特召的怪兽等级更低且至少为1），以及对象离开后我方场上是否有空余怪兽区供特殊召唤。
	return c:IsFaceup() and c:GetOriginalLevel()>1 and Duel.GetMZoneCount(tp,c)>0
		-- 检查卡组中是否存在1只满足filter2条件的怪兽，即能够通过本效果特殊召唤的、与对象原本种族·属性不同且等级更低的怪兽。
		and Duel.IsExistingMatchingCard(c21570001.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
-- 定义卡组内怪兽的筛选条件：该怪兽等级低于对象原本等级，原本种族和原本属性都与对象不同，并且可以被当前效果以表侧守备表示特殊召唤。
function c21570001.filter2(c,e,tp,tc)
	return c:IsLevelBelow(tc:GetOriginalLevel()-1)
		and not c:IsRace(tc:GetOriginalRace())
		and not c:IsAttribute(tc:GetOriginalAttribute())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与操作信息设置：确认有合法对象后，选择自己场上1只表侧表示怪兽作为对象，并登记破坏与特殊召唤的操作信息。
function c21570001.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21570001.filter(chkc,e,tp) end
	-- 发动时点检查场上是否存在至少1只满足filter条件的己方表侧表示怪兽，以此决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(c21570001.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 显示“请选择要破坏的卡”的提示，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只满足filter条件的表侧表示怪兽，将其设为效果对象并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c21570001.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记本连锁的破坏操作信息：破坏对象为所选的怪兽，数量为1，供相关效果（如星尘龙等）检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记本连锁的特殊召唤操作信息：将从卡组特殊召唤1只怪兽（具体对象处理时确定），使相关时点能被正确触发。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：取对象怪兽，若其仍与效果关联则破坏；破坏成功且场上有空位时，从卡组选择符合条件的怪兽特殊召唤，并对其适用效果无效化。
function c21570001.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽仍与效果关联，且被效果成功破坏，并且我方场上有可用怪兽区时，才继续执行特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示“请选择要特殊召唤的卡”的提示，引导玩家选择卡组中的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足filter2条件的怪兽（等级更低、原本种族·属性不同且可特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,c21570001.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc)
		if #g>0 then
			local sc=g:GetFirst()
			-- 以表侧守备表示将选择的怪兽特殊召唤到己方场上，并检查特殊召唤是否成功。
			if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 这个效果特殊召唤的怪兽的效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
				-- 这个效果特殊召唤的怪兽的效果无效化。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
			-- 完成特殊召唤处理（与SpecialSummonStep配对），结束本次特殊召唤。
			Duel.SpecialSummonComplete()
		end
	end
end
