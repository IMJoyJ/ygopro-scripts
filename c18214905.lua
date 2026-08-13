--エレメントセイバー・ラパウィラ
-- 效果：
-- ①：1回合1次，魔法·陷阱卡发动时，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。那个发动无效并破坏。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c18214905.initial_effect(c)
	-- ①：1回合1次，魔法·陷阱卡发动时，从手卡把1只「元素灵剑士」怪兽送去墓地才能发动。那个发动无效并破坏。
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
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18214905,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c18214905.atttg)
	e2:SetOperation(c18214905.attop)
	c:RegisterEffect(e2)
end
-- 该函数判定效果①能否发动：要求正在发动的连锁是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该连锁能够被无效。
function c18214905.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真值：需要同时满足两个条件——发动中的效果re属于魔法陷阱卡的发动类型，且Duel.IsChainNegatable(ev)确认该连锁可被无效。
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 代价过滤函数：选择作为代价送去墓地的怪兽，必须字段为「元素灵剑士」、是怪兽卡且可以作为代价送去墓地。
function c18214905.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：根据场上是否有「灵神的圣殿」，决定从手牌或从手牌+卡组中选取1只满足条件的「元素灵剑士」怪兽送去墓地作为发动代价，若从卡组送墓则消耗灵神的圣殿的次数。
function c18214905.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp是否受到卡号为61557074的「灵神的圣殿」效果的影响，若受影响则允许把卡组的「元素灵剑士」怪兽送去墓地作为代替。
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 代价检测时，确认从可选区域（手牌或手牌+卡组）至少存在1张满足costfilter的「元素灵剑士」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c18214905.costfilter,tp,loc,0,1,nil) end
	-- 向玩家显示选择提示，提示文本为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从符合条件的「元素灵剑士」怪兽中选出1张作为代价，返回这张卡的first对象。
	local tc=Duel.SelectMatchingCard(tp,c18214905.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 当选中的代价卡位于卡组时，向双方展示「灵神的圣殿」的卡片动画，表示使用其代替送墓效果。
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的怪兽卡以代价（REASON_COST）方式送去墓地，完成代价支付。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 效果①的目标处理函数：在发动时记录将无效的对象，并判断能否追加破坏，为后续处理设置操作信息。
function c18214905.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：此连锁将进行发动无效（CATEGORY_NEGATE），作用于正在发动的卡eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动无效的对象卡可以被破坏且与效果仍有联系，则追加设置操作信息：将其破坏（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的发动无效和破坏处理：先使连锁ev的发动无效，若原发动卡仍关联则将其破坏。
function c18214905.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断：发动无效成功，且需要破坏的那张卡仍与效果有联系（未被无效前离开场所等）。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将无效的卡以效果（REASON_EFFECT）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 效果②的目标处理函数：宣言一个属性，并把该墓地效果涉及卡片移动的信息记录到连锁中。
function c18214905.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 显示属性宣言提示，提示文本为“请选择要宣言的属性”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 玩家从全部属性中宣言1个属性，且不能选择这张卡当前的属性；宣言结果通过e:SetLabel(att)保存。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置操作信息：该效果将导致墓地的这张卡离开墓地（CATEGORY_LEAVE_GRAVE），使「王家长眠之谷」等效果可以对应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果②的处理函数：若这张卡仍在墓地且与效果关联，则为它赋予一个改变属性的效果，直到回合结束时变成宣言的属性。
function c18214905.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
