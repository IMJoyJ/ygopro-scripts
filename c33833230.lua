--EMシール・イール
-- 效果：
-- ←3 【灵摆】 3→
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功时，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。这个回合，那张卡不能发动。双方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
function c33833230.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可作为灵摆卡发动并支持灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33833230,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c33833230.distg)
	e1:SetOperation(c33833230.disop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功时，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。这个回合，那张卡不能发动。双方不能对应这个效果的发动把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33833230,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c33833230.lcktg)
	e2:SetOperation(c33833230.lckop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 灵摆效果的目标选择函数：检查并选择对方场上1只表侧表示且效果未被无效的怪兽作为对象，并登记无效效果的操作信息。
function c33833230.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 若已指定对象，则验证该对象是对方场上表侧表示且效果可被无效的怪兽，以确认对象是否合法。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只表侧表示且效果可被无效的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示选择提示，要求选择要无效的怪兽（‘请选择要无效的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让发动玩家从对方场上选择1只符合条件的表侧表示怪兽，并将其设置为效果的对象。
	local g=Duel.SelectTarget(tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：本连锁将执行无效（CATEGORY_DISABLE）处理，对象为所选的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 灵摆效果的处理操作：若效果持有者与对象怪兽仍与效果关联，则使该怪兽效果无效直到回合结束，同时使与其相关的连锁无效化。
function c33833230.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取效果发动时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽相关的连锁无效化，并设定在变里侧表示时重置该无效化。
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
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 怪兽效果的目标选择函数：检查并选择对方场上1张里侧表示的魔法·陷阱卡作为对象，同时设置连锁限制，使双方不能对应此发动连锁魔法·陷阱·怪兽效果。
function c33833230.lcktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 发动合法性检查：确认对方场上存在至少1张里侧表示的魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 向发动玩家显示选择提示，要求选择里侧表示的魔法·陷阱卡（‘请选择里侧表示的卡’）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 让发动玩家从对方场上选择1张里侧表示的魔法·陷阱卡，并将其设置为效果的对象。
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设定连锁限制：双方不能对应此效果的发动把魔法·陷阱·怪兽的效果发动。
	Duel.SetChainLimit(aux.FALSE)
end
-- 怪兽效果的处理操作：若对象仍是里侧表示且仍与效果关联，则给对象附加‘不能发动效果’的无效状态，使其在这个回合不能发动。
function c33833230.lckop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 这个回合，那张卡不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
