--百鬼羅刹 爆音クラッタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「百鬼罗刹 爆音克拉特」以外的自己墓地1只「哥布林」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，对方主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c51473858.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合，以「百鬼罗刹 爆音克拉特」以外的自己墓地1只「哥布林」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51473858,0))  --"特殊召唤墓地怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,51473858)
	e1:SetTarget(c51473858.sptg)
	e1:SetOperation(c51473858.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，对方主要阶段才能发动。场上1个超量素材取除，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51473858,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,51473858+1)
	e3:SetCondition(c51473858.spcon2)
	e3:SetTarget(c51473858.sptg2)
	e3:SetOperation(c51473858.spop2)
	c:RegisterEffect(e3)
end
-- 过滤器：选择墓地中卡名含「哥布林」、不是「百鬼罗刹 爆音克拉特」且能够被特殊召唤（允许表侧守备表示）的怪兽。
function c51473858.filter(c,e,tp)
	return c:IsSetCard(0xac) and not c:IsCode(51473858) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件与取对象处理：自己主要怪兽区有空位，且墓地存在符合条件的「哥布林」怪兽时，可为效果选择1只作为对象。
function c51473858.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51473858.filter(chkc,e,tp) end
	-- 发动合法性检查：自己主要怪兽区是否有空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性检查：自己墓地是否存在满足过滤器且可成为效果对象的「哥布林」怪兽。
		and Duel.IsExistingTarget(c51473858.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地中选出1只符合条件的「哥布林」怪兽，并设为效果对象。
	local g=Duel.SelectTarget(tp,c51473858.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次效果将把所选择的对象特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：取回对象怪兽，若其仍与效果关联，则将其特殊召唤到自己场上。
function c51473858.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡在墓地存在，且当前为对方回合的主要阶段（主要阶段1或2）。
function c51473858.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方回合，且阶段为主要阶段1或2。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- ②效果的发动合法性检查：能够移除场上1个超量素材、自己怪兽区有空位，且这张卡自身可以被特殊召唤。
function c51473858.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果的发动条件：以效果原因可以移除场上1个超量素材，并且自己主要怪兽区有空位。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果将把墓地的这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：先移除1个超量素材，成功后若这张卡仍与效果关联则将其特殊召唤；若召唤成功，为其附加离场时除外的效果，并完成整个特殊召唤流程。
function c51473858.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 实际移除场上1个超量素材；若移除成功且这张卡仍可受效果影响，则继续特殊召唤处理。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 尝试将这张卡以表侧攻击表示特殊召唤（使用分步特殊召唤以便附加后续离场除外效果）。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
		-- 完成分步特殊召唤的最终处理，结算该次特殊召唤。
		Duel.SpecialSummonComplete()
	end
end
