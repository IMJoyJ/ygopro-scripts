--幻影騎士団カースド・ジャベリン
-- 效果：
-- 2星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这张卡有「幻影骑士团」卡在作为超量素材的场合，这个效果在对方回合也能发动）。那只怪兽直到回合结束时攻击力变成0，效果无效化。
function c12219047.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：需要2只2星怪兽作为超量素材才能XYZ召唤。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 2星怪兽×2。这个卡名的效果1回合只能使用1次。①：把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动（这张卡有「幻影骑士团」卡在作为超量素材的场合，这个效果在对方回合也能发动）。那只怪兽直到回合结束时攻击力变成0，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12219047,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,12219047)
	e1:SetCondition(c12219047.condition1)
	e1:SetCost(c12219047.cost)
	e1:SetTarget(c12219047.target)
	e1:SetOperation(c12219047.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,0x21e0)
	e2:SetCondition(c12219047.condition2)
	c:RegisterEffect(e2)
end
-- 起动效果的发动条件：这张卡没有「幻影骑士团」卡作为超量素材时才可作为起动效果在主要阶段发动。
function c12219047.condition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
end
-- 发动代价：确认并取除这张卡的1个超量素材（REASON_COST）。
function c12219047.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象选择用过滤器：对方场上的表侧表示怪兽，且攻击力大于0或属于可被效果无效化的效果怪兽，以保证效果能生效。
function c12219047.filter(c)
	-- 返回该怪兽是否为表侧表示，且攻击力大于0或可被无效化。
	return c:IsFaceup() and (c:GetAttack()>0 or aux.NegateMonsterFilter(c))
end
-- 取对象效果的目标处理：在对方怪兽区选择1只满足过滤器的表侧表示怪兽作为对象。
function c12219047.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c12219047.filter(chkc) end
	-- 发动合法性检查：确认对方怪兽区是否存在至少1只满足过滤器且能成为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c12219047.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 令玩家从对方怪兽区选择1只满足过滤器的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,c12219047.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若对象仍表侧且与效果有关联，则无效其相关连锁，并给它附加“攻击力变成0、效果无效化”直到回合结束的持续效果。
function c12219047.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取回发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使对象怪兽发动的相关连锁效果无效化，并设定里侧表示重置该无效状态的时机。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对应“那只怪兽直到回合结束时……效果无效化”中的效果无效化：无效对象怪兽的怪兽效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对应“那只怪兽直到回合结束时……效果无效化”中的效果无效化：无效对象怪兽已经适用的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 对应“那只怪兽直到回合结束时攻击力变成0”：将对象怪兽的攻击力变成0。
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(0)
		tc:RegisterEffect(e3)
	end
end
-- 对方回合快速效果的发动条件：这张卡有「幻影骑士团」卡作为超量素材，且满足伤害步骤内/外的可发动时点条件。
function c12219047.condition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x10db)
		-- 伤害步骤限制条件：当前不是伤害步骤，或者处于伤害步骤但尚未进行伤害计算，才可发动。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
