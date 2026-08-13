--DDドッグ
-- 效果：
-- ←3 【灵摆】 3→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以对方场上1只融合·同调·超量怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，灵摆区域的这张卡破坏。
-- 【怪兽效果】
-- ①：1回合1次，对方对融合·同调·超量怪兽的特殊召唤成功的场合，以那1只怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能攻击，效果无效化。
function c32349062.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤、灵摆区域发动能力），使其可以作为灵摆卡使用。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以对方场上1只融合·同调·超量怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。那之后，灵摆区域的这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32349062,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,32349062)
	e1:SetTarget(c32349062.distg1)
	e1:SetOperation(c32349062.disop1)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方对融合·同调·超量怪兽的特殊召唤成功的场合，以那1只怪兽为对象才能发动。这个回合，那只表侧表示怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32349062,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c32349062.discon2)
	e2:SetTarget(c32349062.distg2)
	e2:SetOperation(c32349062.disop2)
	c:RegisterEffect(e2)
end
-- 定义效果的目标筛选函数：筛选出融合·同调·超量怪兽，且为表侧表示、未被无效、可被无效的效果怪兽。
function c32349062.filter(c)
	-- 具体筛选条件：怪兽属于融合、同调或超量类型，并且是可被无效的表侧效果怪兽。
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and aux.NegateMonsterFilter(c)
end
-- 灵摆效果发动时的目标选择处理：确认对方场上存在可选择的融合·同调·超量怪兽后，选择其中1只作为对象，并设置破坏这张灵摆卡的操作信息。
function c32349062.distg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32349062.filter(chkc) end
	-- 发动合法性检查：若对方场上不存在符合条件的融合·同调·超量怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c32349062.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让玩家从对方场上选择1只符合条件的融合·同调·超量怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c32349062.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁预定将效果持有者（这张灵摆卡）破坏1张，供后续破坏处理及卡组能力检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果处理：取对象怪兽，若其仍与效果相关且表侧表示并能被无效，则使其相关连锁无效，并给对象附加怪兽效果无效与效果文本无效的状态；若这张卡仍在灵摆区域，则中断处理后将其破坏。
function c32349062.disop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		-- 使对象怪兽相关的连锁无效化，并设置该无效状态在怪兽变里侧或回合结束时重置。
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
		if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_PZONE) then
			-- 中断当前效果处理，使后续的破坏处理与之前的无效处理视为不同时点，避免错过时点。
			Duel.BreakEffect()
			-- 以效果原因将这张卡破坏（此时其仍在灵摆区域）。
			Duel.Destroy(c,REASON_EFFECT)
		end
	end
end
-- 定义特殊召唤成功时点的过滤函数：判断怪兽是否为对方特殊召唤成功的融合·同调·超量怪兽，且为可被无效的表侧效果怪兽。
function c32349062.cfilter(c,tp)
	-- 具体条件：怪兽表侧表示、召唤玩家是对方、属于融合·同调·超量类型，并且是可被无效的表侧效果怪兽。
	return c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and aux.NegateMonsterFilter(c)
end
-- 发动条件判定：本次特殊召唤成功的怪兽中至少存在1只满足条件的融合·同调·超量怪兽时，效果才能发动。
function c32349062.discon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32349062.cfilter,1,nil,tp)
end
-- 定义目标选择过滤器：判断候选卡是否属于本次特殊召唤成功且符合条件的那组怪兽。
function c32349062.disfilter(c,g)
	return g:IsContains(c)
end
-- 怪兽效果的目标选择处理：从对方本次特殊召唤成功的符合条件的怪兽中选取1只作为对象；若只有1只则自动设置，若有多只则手动选择。
function c32349062.distg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c32349062.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32349062.disfilter(chkc,g) end
	-- 发动合法性检查：若场上不存在可作为对象的符合条件的怪兽，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c32349062.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	if g:GetCount()==1 then
		-- 当符合条件的怪兽只有1只时，直接将其登记为当前连锁的效果对象。
		Duel.SetTargetCard(g)
	else
		-- 显示选择提示，提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 当存在多只符合条件的怪兽时，让玩家选择其中1只，并登记为效果对象。
		Duel.SelectTarget(tp,c32349062.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
end
-- 怪兽效果处理：使对象怪兽这个回合不能攻击；若对象怪兽未被无效，则使其相关连锁无效，并给对象附加怪兽效果无效与效果文本无效的状态。
function c32349062.disop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只表侧表示怪兽不能攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		if not tc:IsDisabled() then
			-- 使对象怪兽相关的连锁无效化，并设置该无效状态在怪兽变里侧或回合结束时重置。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 效果无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
