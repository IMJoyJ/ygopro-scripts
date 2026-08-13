--弓神レライエ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。这张卡的攻击力直到回合结束时上升自己墓地的怪兽的种族种类×100。
-- ②：以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力下降这张卡的攻击力数值。这个效果让那只怪兽的守备力变成0的场合，再把那只怪兽破坏。这个效果的发动后，直到回合结束时这张卡不能攻击。
function c49922726.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。这张卡的攻击力直到回合结束时上升自己墓地的怪兽的种族种类×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49922726,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c49922726.atktg)
	e1:SetOperation(c49922726.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力下降这张卡的攻击力数值。这个效果让那只怪兽的守备力变成0的场合，再把那只怪兽破坏。这个效果的发动后，直到回合结束时这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49922726,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,49922726)
	e2:SetTarget(c49922726.destg)
	e2:SetOperation(c49922726.desop)
	c:RegisterEffect(e2)
end
-- ①效果的target函数：检查自己墓地是否有怪兽，作为①效果的发动条件。
function c49922726.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动判定：chk==0时，检查自己墓地是否存在至少1只怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER) end
end
-- ①效果处理函数：获取自己墓地所有怪兽，按种族种类数×100计算上升值，若这张卡仍表侧且效果有效，则赋予其攻击力上升效果直到回合结束。
function c49922726.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己墓地的所有怪兽卡，用于统计种族种类数。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local val=g:GetClassCount(Card.GetRace)*100
	if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
		-- 这张卡的攻击力直到回合结束时上升自己墓地的怪兽的种族种类×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- ②效果选择对象的过滤函数：要求怪兽为表侧表示且当前守备力大于0。
function c49922726.desfilter(c)
	return c:IsFaceup() and c:GetDefense()>0
end
-- ②效果的target函数：检查这张卡攻击力大于0且场上有满足条件的对象；发动时选择一张除自身以外的表侧表示且守备力大于0的怪兽作为对象，并登记守备力变化操作信息。
function c49922726.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49922726.desfilter(chkc) and chkc~=c end
	-- 发动条件判定：chk==0时，检查这张卡攻击力大于0，且场上存在除这张卡以外的表侧表示且守备力大于0的怪兽。
	if chk==0 then return c:GetAttack()>0 and Duel.IsExistingTarget(c49922726.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向玩家显示选择提示，要求选择一张表侧表示的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c49922726.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 登记操作信息：本连锁将进行守备力变化（对象为选中的怪兽，数量1），供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,1,0,0)
end
-- ②效果处理函数：先给这张卡附加‘不能攻击’效果；然后使对象怪兽守备力下降这张卡当前攻击力的数值；若对象守备力因此变成0，则将其破坏。
function c49922726.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个效果的发动后，直到回合结束时这张卡不能攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=c:GetAttack()
		local def=tc:GetDefense()
		-- 那只怪兽的守备力下降这张卡的攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if def~=0 and tc:IsDefense(0) then
			-- 中断当前效果处理，使随后的破坏处理与之前的守备力变化不在同一时点，以正确触发相关时点。
			Duel.BreakEffect()
			-- 将对象怪兽以效果破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
