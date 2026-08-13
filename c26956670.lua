--化石岩の解放
-- 效果：
-- 选择1只被除外的自己的岩石族怪兽在自己场上特殊召唤。这张卡从场上离开时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c26956670.initial_effect(c)
	-- 选择1只被除外的自己的岩石族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c26956670.target)
	e1:SetOperation(c26956670.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c26956670.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c26956670.descon2)
	e3:SetOperation(c26956670.desop2)
	c:RegisterEffect(e3)
end
-- 怪兽的筛选条件：必须是表侧表示的岩石族怪兽，且能够被当前效果特殊召唤。
function c26956670.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的对象选择与合法性判定：若检查对象则为除外区且自己控制的岩石族可特召怪兽；若为发动时点，则确认自己主怪兽区有空位且存在至少1只符合条件的除外区岩石族怪兽。
function c26956670.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c26956670.filter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己除外区是否存在至少1只满足筛选条件的岩石族怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c26956670.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 自己从除外区选择1只符合条件的岩石族怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c26956670.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：将进行1只怪兽的特殊召唤，用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若这张魔法卡和对象怪兽仍与本次效果关联，且对象仍为岩石族，则尝试将其特殊召唤；成功后让这张卡以该怪兽为永续对象，以维持后续关联。
function c26956670.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsRace(RACE_ROCK)
		-- 使用分步特殊召唤步骤，将对象怪兽以表侧表示特殊召唤到自己场上，该步骤会检查召唤是否合法。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成分步特殊召唤的收尾处理，实际完成特殊召唤。
	Duel.SpecialSummonComplete()
end
-- 这张卡从场上离开时，若其永续对象的怪兽仍在怪兽区，则将该怪兽破坏。
function c26956670.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将那只对象怪兽破坏，破坏原因记为效果。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检测条件：这张卡的永续对象怪兽因破坏而离场时，条件成立（eg中包含该怪兽且其破坏原因是破坏）。
function c26956670.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当对象怪兽被破坏时，这张卡自身也被破坏。
function c26956670.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡自身破坏，破坏原因记为效果。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
