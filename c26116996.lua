--祟リ紙ノ報イ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽和对方场上1张表侧表示卡为对象才能发动。那只自己怪兽破坏，那张对方的卡的效果直到回合结束时无效。
-- ②：盖放的这张卡被送去墓地的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
local s,id,o=GetID()
-- 注册这张卡的两个效果：e1为①效果（魔陷发动，自由时点，破坏自己怪兽并无效对方的卡，1回合1次），e2为②效果（盖放的这张卡送去墓地时触发的诱发选发效果，无效对方的卡，1回合1次）
function s.initial_effect(c)
	-- ①：以自己场上1只怪兽和对方场上1张表侧表示卡为对象才能发动。那只自己怪兽破坏，那张对方的卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被送去墓地的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- ①效果的对象选择处理：选择自己场上1只怪兽和对方场上1张可被无效的表侧表示卡为对象，记录要破坏的怪兽，并设置破坏和无效的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 发动条件检查：确认自己场上存在可以成为对象的怪兽，且对方场上存在可以成为对象的可被无效的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以自己场上1只怪兽为对象（要破坏的怪兽）
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向玩家提示：请选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 以对方场上1张可被无效的表侧表示卡为对象（要无效的卡）
	local g2=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 设置连锁的操作信息：这个效果将破坏1张卡（选择的自己怪兽）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置连锁的操作信息：这个效果将无效1张卡（选择的对方的卡）
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g2,1,0,0)
end
-- ①效果的处理：破坏对象的自己怪兽，破坏成功后将对象的对方的卡的效果直到回合结束时无效（若是陷阱怪兽则当作陷阱卡无效）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得与本连锁相关的所有对象卡
	local g=Duel.GetTargetsRelateToChain()
	local tc1=e:GetLabelObject()
	if not g:IsContains(tc1) or not tc1:IsControler(tp) or not tc1:IsType(TYPE_MONSTER) then return end
	-- 用效果破坏那只自己怪兽，若破坏成功则继续处理无效
	if Duel.Destroy(tc1,REASON_EFFECT)~=0 then
		-- 从对象卡中筛选出要无效的对方的卡（排除被破坏的怪兽）
		local tc2=g:Filter(aux.NegateAnyFilter,tc1):GetFirst()
		if tc2 and tc2:IsControler(1-tp) and tc2:IsCanBeDisabledByEffect(e,false) then
			-- 将与那张对方的卡相关的连锁无效化（直到其变为里侧表示为止）
			Duel.NegateRelatedChain(tc2,RESET_TURN_SET)
			-- 那张对方的卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e1)
			-- 那张对方的卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc2:RegisterEffect(e2)
			if tc2:IsType(TYPE_TRAPMONSTER) then
				-- 那张对方的卡的效果直到回合结束时无效（作为陷阱怪兽的场合，其作为怪兽的效果也无效）。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc2:RegisterEffect(e3)
			end
		end
	end
end
-- ②效果的发动条件：这张卡之前在场上且以盖放（里侧表示）状态存在，即盖放的这张卡被送去墓地的场合
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- ②效果的对象选择处理：以对方场上1张可被无效的表侧表示卡为对象，并设置无效的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象合法性检查：对象必须是对方场上可被无效的表侧表示卡
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动条件检查：确认对方场上存在可以成为对象的可被无效的表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示：请选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 以对方场上1张可被无效的表侧表示卡为对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：这个效果将无效1张卡（选择的对方的卡）
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②效果的处理：将对象的对方的卡的效果无效（若是陷阱怪兽则当作陷阱卡无效）
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这个效果的对象卡（要无效的对方的卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 将与那张卡相关的连锁无效化（直到其变为里侧表示为止）
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那张卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果无效（作为陷阱怪兽的场合，其作为怪兽的效果也无效）。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
