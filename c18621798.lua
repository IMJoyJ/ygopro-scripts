--炎王獣 ガネーシャ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在怪兽区域存在，怪兽的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
-- ②：这张卡被破坏送去墓地的场合，以「炎王兽 甘尼许」以外的自己墓地1只兽族·兽战士族·鸟兽族的炎属性怪兽为对象才能发动。那只怪兽特殊召唤。那只怪兽的效果无效化，结束阶段破坏。
function c18621798.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡在怪兽区域存在，怪兽的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
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
	-- ②：这张卡被破坏送去墓地的场合，以「炎王兽 甘尼许」以外的自己墓地1只兽族·兽战士族·鸟兽族的炎属性怪兽为对象才能发动。那只怪兽特殊召唤。那只怪兽的效果无效化，结束阶段破坏。
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
-- ①效果的发动条件判定：本卡在怪兽区域存在，且被无效的连锁是怪兽效果的发动，本卡未处于战斗破坏确定状态，且该连锁可以被无效。
function c18621798.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 具体条件：连锁的效果是怪兽效果，本卡不处于战斗破坏确定状态，并允许无效该连锁。
	return re:IsActiveType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 筛选可破坏的怪兽：自己的手卡·场上表侧表示的炎属性怪兽。
function c18621798.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx()
end
-- ①效果发动时的目标判定：先检查是否存在符合条件的破坏对象，再登记“无效发动”和“破坏1张手卡/场上表侧炎属性怪兽”的操作信息。
function c18621798.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有1张以上的符合条件的可破坏炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c18621798.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 登记操作信息：使当前连锁的怪兽效果发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 登记操作信息：本次效果将破坏1张自己的手卡/场上表侧表示的炎属性怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ①效果处理：若该怪兽效果的发动被无效，则从自己的手卡/场上表侧表示的炎属性怪兽中选择1张并破坏。
function c18621798.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前连锁的发动，成功才执行后续破坏处理。
	if Duel.NegateActivation(ev) then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家从自己的手卡/场上表侧表示的炎属性怪兽中选出1张作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,c18621798.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,e:GetHandler())
		if g:GetCount()>0 then
			-- 将所选卡以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件判定：此卡是被破坏后送去墓地的场合。
function c18621798.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 筛选可特殊召唤的怪兽：自己墓地中，卡名不是「炎王兽 甘尼许」，炎属性且兽族·兽战士族·鸟兽族，并且满足可特殊召唤条件。
function c18621798.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		and not c:IsCode(18621798) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的目标有效性检查与条件确认：确认对象合法且墓地存在可特殊召唤的目标。
function c18621798.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c18621798.spfilter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件且能成为效果对象的炎属性怪兽。
		and Duel.IsExistingTarget(c18621798.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1张符合条件的怪兽，并设为效果处理时的对象。
	local g=Duel.SelectTarget(tp,c18621798.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本次处理将进行特殊召唤，对象为所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将目标怪兽特殊召唤；若成功，使其效果无效化，并在结束阶段将其破坏。
function c18621798.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这次效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽与效果仍有联系，并以表侧表示进行特殊召唤（成功则继续附加无效化与破坏效果）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=c:GetFieldID()
		-- 那只怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(18621798,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 结束阶段破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetLabel(fid)
		e4:SetLabelObject(tc)
		e4:SetCondition(c18621798.descon)
		e4:SetOperation(c18621798.desop)
		-- 将结束阶段破坏效果作为场上持续效果注册给当前玩家。
		Duel.RegisterEffect(e4,tp)
	end
	-- 完成整个流程中的特殊召唤处理（与SpecialSummonStep配对使用）。
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏效果的发动条件：若该怪兽仍然持有本次特殊召唤的标记，则满足条件；否则重置该效果并拒绝发动。
function c18621798.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(18621798)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 结束阶段处理：将对应的怪兽破坏。
function c18621798.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 以效果原因破坏目标怪兽。
	Duel.Destroy(tc,REASON_EFFECT)
end
