--彼岸の悪鬼 アリキーノ
-- 效果：
-- 「彼岸的恶鬼 阿利基诺」的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c47728740.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c47728740.sdcon)
	c:RegisterEffect(e1)
	-- 「彼岸的恶鬼 阿利基诺」的①③的效果1回合只能有1次使用其中任意1个。①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47728740,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,47728740)
	e2:SetCondition(c47728740.sscon)
	e2:SetTarget(c47728740.sstg)
	e2:SetOperation(c47728740.ssop)
	c:RegisterEffect(e2)
	-- 「彼岸的恶鬼 阿利基诺」的①③的效果1回合只能有1次使用其中任意1个。③：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47728740,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,47728740)
	e3:SetTarget(c47728740.distg)
	e3:SetOperation(c47728740.disop)
	c:RegisterEffect(e3)
end
-- 过滤条件：用于②的自我破坏判定，判断怪兽是否为里侧表示或不属于「彼岸」系列；存在这样的怪兽时返回true。
function c47728740.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- ②效果的触发条件：在自己场上存在里侧表示怪兽或非「彼岸」怪兽（即满足sdfilter的怪兽）时，这张卡自我破坏。
function c47728740.sdcon(e)
	-- 检索自己场上是否有1张以上里侧表示或不属于「彼岸」系列的怪兽，有则返回真。
	return Duel.IsExistingMatchingCard(c47728740.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：判断卡片是否为魔法·陷阱卡，用于检查自己场上是否存在魔法·陷阱卡。
function c47728740.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动条件：自己场上不存在魔法·陷阱卡时才能发动。
function c47728740.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上没有魔法·陷阱卡（不存在满足filter的卡）的判定结果，没有则返回真。
	return not Duel.IsExistingMatchingCard(c47728740.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的目标判定：在发动检查时确认自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c47728740.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段（chk==0），确认自己场上的主要怪兽区域有空位可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：本次效果将进行特殊召唤，对象为这张卡自身，数量为1，用于连锁和后续判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的特殊召唤处理：取得这张卡，若其仍与效果关联，则将其以表侧表示特殊召唤到自己场上；否则不作处理。
function c47728740.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的目标选择：选择场上1只表侧表示且能被无效的效果怪兽作为对象，以发动无效其效果。
function c47728740.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理中校验已选对象：对象必须是表侧表示、可被无效的怪兽且位于怪兽区域。
	if chkc then return aux.NegateMonsterFilter(chkc) and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动合法性检查：场上是否存在至少1只表侧表示且可被无效的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示提示信息，要求选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只表侧表示且可被无效的怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ③效果处理：取得对象怪兽，若其仍与效果关联、表侧表示且能被此效果无效，则将其效果直到回合结束时无效。
function c47728740.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得③效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使对象怪兽关联的连锁（若存在）无效化，以配合后续的无效效果处理。
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
