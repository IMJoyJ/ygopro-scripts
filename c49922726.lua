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
	-- ②：以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的守备力下降这张卡的攻击力数值。这个效果让那只怪兽的守备力变成0的场合，再把那只怪兽破坏。这个效果的发动后，直到回合结束时这张卡不能攻击。
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
-- 检查自己墓地是否存在怪兽卡
function c49922726.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_MONSTER) end
end
-- 检索满足条件的卡片组并计算攻击力提升值
function c49922726.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检索满足条件的卡片组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	local val=g:GetClassCount(Card.GetRace)*100
	if c:IsFaceup() and c:IsRelateToEffect(e) and val>0 then
		-- 将攻击力提升效果应用到自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 筛选目标怪兽是否为表侧表示且守备力大于0
function c49922726.desfilter(c)
	return c:IsFaceup() and c:GetDefense()>0
end
-- 设置效果发动时的目标选择逻辑
function c49922726.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c49922726.desfilter(chkc) and chkc~=c end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return c:GetAttack()>0 and Duel.IsExistingTarget(c49922726.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c49922726.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置操作信息，用于后续处理
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,1,0,0)
end
-- 处理效果发动后的操作
function c49922726.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身在本回合不能攻击
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
		-- 将目标怪兽的守备力减少自身攻击力数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(-atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if def~=0 and tc:IsDefense(0) then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 破坏目标怪兽
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
