--巨骸竜フェルグラント
-- 效果：
-- 不死族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡已在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册同调召唤手续以及①②的效果。
function c65187687.initial_effect(c)
	-- 同调召唤材料要求：不死族调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,c65187687.synfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,65187687)
	e1:SetTarget(c65187687.rmtg)
	e1:SetOperation(c65187687.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上怪兽效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,65187687+o)
	e2:SetCondition(c65187687.discon)
	e2:SetTarget(c65187687.distg)
	e2:SetOperation(c65187687.disop)
	c:RegisterEffect(e2)
end
-- 同调素材调整筛选条件：必须是不死族怪兽。
function c65187687.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- ①效果除外目标过滤条件：必须是怪兽且可以除外。
function c65187687.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①效果的发动准备与选择目标：在对方的场上或墓地选择1只怪兽作为对象，并设置除外操作信息。
function c65187687.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c65187687.rmfilter(chkc) end
	-- 检查对方的场上或墓地是否存在至少1只可除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c65187687.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 显示提示信息：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 优先从对方场上（若场上无合法目标则从对方墓地）选择1只怪兽作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,c65187687.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 设置效果处理信息：从对方墓地将1张卡除外。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 设置效果处理信息：将目标1张卡除外。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- ①效果的处理：若目标卡仍与效果相关，则将其表侧表示除外。
function c65187687.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 触发条件过滤：检查特殊召唤的卡原本是否为怪兽且是否从墓地特殊召唤。
function c65187687.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ②效果的发动条件：存在从墓地特殊召唤的怪兽且其中不包含自身。
function c65187687.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65187687.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ②效果的发动准备与选择目标：在场上选择1只表侧表示的效果怪兽作为对象。
function c65187687.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 重选择目标时的过滤：检查目标卡是否在怪兽区且为可被无效效果的表侧表示怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查场上是否存在至少1只效果可以被无效的表侧表示效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示提示信息：请选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只效果可以被无效的表侧表示效果怪兽作为对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果的处理：使选中的目标怪兽的效果直到回合结束时无效。
function c65187687.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与目标卡片相关的连锁中已发动的效果无效。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
