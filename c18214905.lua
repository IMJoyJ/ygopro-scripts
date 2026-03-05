--エレメントセイバー・ラパウィラ
-- 效果：
-- ①：1回合1次，魔法·陷阱卡发动时，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c18214905.initial_effect(c)
	-- 效果原文内容：①：1回合1次，魔法·陷阱卡发动时，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18214905,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c18214905.negcon)
	e1:SetCost(c18214905.negcost)
	e1:SetTarget(c18214905.negtg)
	e1:SetOperation(c18214905.negop)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18214905,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c18214905.atttg)
	e2:SetOperation(c18214905.attop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断是否为魔法或陷阱卡的发动，且该连锁是否可以被无效。
function c18214905.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否为魔法或陷阱卡的发动，且该连锁是否可以被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 规则层面作用：定义用于支付费用的过滤函数，筛选手卡中「元素灵剑士」怪兽。
function c18214905.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 规则层面作用：处理效果发动的费用，从手卡或卡组选择一只「元素灵剑士」怪兽送去墓地。
function c18214905.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查玩家是否受到效果影响，用于判断是否可以选卡组中的卡作为费用。
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 规则层面作用：检查是否有满足条件的卡可以作为费用支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c18214905.costfilter,tp,loc,0,1,nil) end
	-- 规则层面作用：提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 规则层面作用：选择满足条件的卡作为费用。
	local tc=Duel.SelectMatchingCard(tp,c18214905.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 规则层面作用：显示提示动画，表示使用了特定卡的效果。
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 规则层面作用：将选中的卡送去墓地作为费用。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 规则层面作用：设置效果处理时的操作信息，包括使发动无效和破坏目标卡。
function c18214905.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置使发动无效的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：设置破坏目标卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规则层面作用：执行效果处理，使连锁发动无效并破坏目标卡。
function c18214905.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否成功使连锁发动无效并确认目标卡是否有效。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 规则层面作用：破坏目标卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 规则层面作用：设置效果处理时的操作信息，包括宣言属性。
function c18214905.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：提示玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 规则层面作用：让玩家宣言一个属性。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 规则层面作用：设置将此卡从墓地移出的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 规则层面作用：执行效果处理，使此卡在本回合内变成宣言的属性。
function c18214905.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面作用：创建一个使此卡属性改变的效果，并在回合结束时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
