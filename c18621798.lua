--炎王獣 ガネーシャ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在，怪兽的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
-- ②：这张卡被破坏送去墓地的场合，以「炎王兽 甘尼许」以外的自己墓地1只兽族·兽战士族·鸟兽族的炎属性怪兽为对象才能发动。那只怪兽特殊召唤。那只怪兽的效果无效化，结束阶段破坏。
function c18621798.initial_effect(c)
	-- 效果原文内容：①：这张卡在怪兽区域存在，怪兽的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18621798,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,18621798)
	e1:SetCondition(c18621798.negcon)
	e1:SetTarget(c18621798.negtg)
	e1:SetOperation(c18621798.negop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡被破坏送去墓地的场合，以「炎王兽 甘尼许」以外的自己墓地1只兽族·兽战士族·鸟兽族的炎属性怪兽为对象才能发动。那只怪兽特殊召唤。那只怪兽的效果无效化，结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18621798,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,18621799)
	e2:SetCondition(c18621798.spcon)
	e2:SetTarget(c18621798.sptg)
	e2:SetOperation(c18621798.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否满足①效果的发动条件，即对方怪兽效果发动时且自身未在战斗破坏状态且该连锁可被无效。
function c18621798.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 规则层面作用：检查对方发动的连锁是否为怪兽卡类型、自身未处于战斗破坏状态、且该连锁可以被无效。
	return re:IsActiveType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 规则层面作用：定义过滤函数，用于筛选自己场上或手牌中表侧表示的炎属性怪兽。
function c18621798.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx()
end
-- 规则层面作用：设置①效果的处理信息，包括使发动无效和破坏目标怪兽。
function c18621798.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否满足①效果发动的条件，即自己场上或手牌中是否存在符合条件的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18621798.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 规则层面作用：设置连锁处理信息，标记该效果会使得发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 规则层面作用：设置连锁处理信息，标记该效果会破坏1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- 规则层面作用：执行①效果的处理流程，先使连锁无效，再选择并破坏符合条件的怪兽。
function c18621798.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：尝试使当前连锁无效，若成功则继续执行后续破坏操作。
	if Duel.NegateActivation(ev) then
		-- 规则层面作用：提示玩家选择要破坏的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 规则层面作用：从自己场上或手牌中选择1只符合条件的炎属性怪兽。
		local g=Duel.SelectMatchingCard(tp,c18621798.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,e:GetHandler())
		if g:GetCount()>0 then
			-- 规则层面作用：将选中的怪兽破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 规则层面作用：判断是否满足②效果的发动条件，即自身因破坏而进入墓地。
function c18621798.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 规则层面作用：定义过滤函数，用于筛选自己墓地中符合条件的炎属性兽族怪兽。
function c18621798.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and not c:IsCode(18621798) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置②效果的处理信息，包括选择目标怪兽并准备特殊召唤。
function c18621798.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18621798.spfilter(chkc,e,tp) end
	-- 规则层面作用：检查是否满足②效果发动的条件，即自己墓地是否存在符合条件的怪兽且场上还有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查自己墓地中是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c18621798.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从自己墓地中选择1只符合条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c18621798.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁处理信息，标记该效果会特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：执行②效果的处理流程，特殊召唤目标怪兽并使其效果无效，同时设置结束阶段破坏。
function c18621798.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面作用：获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：判断目标怪兽是否有效且是否可以特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=c:GetFieldID()
		-- 效果原文内容：那只怪兽的效果无效化，结束阶段破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果原文内容：那只怪兽的效果无效化，结束阶段破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(18621798,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 效果原文内容：那只怪兽的效果无效化，结束阶段破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetLabel(fid)
		e4:SetLabelObject(tc)
		e4:SetCondition(c18621798.descon)
		e4:SetOperation(c18621798.desop)
		-- 规则层面作用：将结束阶段破坏效果注册到场上。
		Duel.RegisterEffect(e4,tp)
	end
	-- 规则层面作用：完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 规则层面作用：判断是否到了结束阶段并触发破坏效果。
function c18621798.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(18621798)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 规则层面作用：执行破坏操作。
function c18621798.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 规则层面作用：将目标怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT)
end
