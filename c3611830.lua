--創聖魔導王 エンディミオン
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：把自己场上6个魔力指示物取除才能发动。灵摆区域的这张卡特殊召唤。那之后，选最多有自己场上的可以放置魔力指示物的卡数量的场上的卡破坏，破坏数量的魔力指示物给这张卡放置。
-- 【怪兽效果】
-- ①：1回合1次，魔法·陷阱卡的效果发动时才能发动。选自己场上1张有魔力指示物放置的卡回到持有者手卡，那个发动无效并破坏。那之后，可以把回到手卡的那张卡放置的数量的魔力指示物给这张卡放置。
-- ②：有魔力指示物放置的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：有魔力指示物放置的这张卡被战斗破坏时才能发动。从卡组把1张通常魔法卡加入手卡。
function c3611830.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以进行灵摆召唤并能作为灵摆卡发动
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ←8 【灵摆】 8→ 这个卡名的灵摆效果1回合只能使用1次。①：把自己场上6个魔力指示物取除才能发动。灵摆区域的这张卡特殊召唤。那之后，选最多有自己场上的可以放置魔力指示物的卡数量的场上的卡破坏，破坏数量的魔力指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3611830,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,3611830)
	e1:SetCost(c3611830.descost)
	e1:SetTarget(c3611830.destg)
	e1:SetOperation(c3611830.desop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，魔法·陷阱卡的效果发动时才能发动。选自己场上1张有魔力指示物放置的卡回到持有者手卡，那个发动无效并破坏。那之后，可以把回到手卡的那张卡放置的数量的魔力指示物给这张卡放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3611830,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c3611830.negcon)
	e2:SetTarget(c3611830.negtg)
	e2:SetOperation(c3611830.negop)
	c:RegisterEffect(e2)
	-- ②：有魔力指示物放置的这张卡不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c3611830.ctcon)
	-- 设置对象抗性过滤值：仅对对方发动的效果生效，使这张卡不会成为对方的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：有魔力指示物放置的这张卡不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c3611830.ctcon)
	-- 设置破坏抗性过滤值：仅对对方发动的效果生效，使这张卡不会被对方的效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ②：有魔力指示物放置的这张卡被战斗破坏时才能发动（离场前记录放置的魔力指示物数量，供后续效果判定）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c3611830.regop)
	c:RegisterEffect(e5)
	-- ③：有魔力指示物放置的这张卡被战斗破坏时才能发动。从卡组把1张通常魔法卡加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DESTROYED)
	e6:SetCondition(c3611830.thcon)
	e6:SetTarget(c3611830.thtg)
	e6:SetOperation(c3611830.thop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
c3611830.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果的代价：把自己场上6个魔力指示物取除才能发动
function c3611830.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：自己场上是否存在可以作为代价取除的6个魔力指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,6,REASON_COST) end
	-- 作为发动代价把自己场上6个魔力指示物取除
	Duel.RemoveCounter(tp,1,0,0x1,6,REASON_COST)
end
-- 过滤函数：判断卡片是否可以放置魔力指示物
function c3611830.cfilter(c)
	return c:IsCanHaveCounter(0x1)
end
-- 灵摆效果的目标处理：检查这张卡能否特殊召唤以及能否放置魔力指示物
function c3611830.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区有空位且灵摆区域的这张卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且检查这张卡能够放置魔力指示物
		and Duel.IsCanAddCounter(tp,0x1,1,c) end
	-- 取得双方场上存在的所有卡，作为可能被破坏的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：宣告此效果包含破坏场上至少1张卡的破坏处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：宣告此效果包含把这张卡特殊召唤的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果处理：灵摆区域的这张卡特殊召唤，那之后破坏场上的卡并放置破坏数量的魔力指示物
function c3611830.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关，则把灵摆区域的这张卡特殊召唤，特殊召唤成功才继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 统计自己场上可以放置魔力指示物的卡的数量，作为最多可破坏的卡数
		local ct=Duel.GetMatchingGroupCount(c3611830.cfilter,tp,LOCATION_ONFIELD,0,nil)
		if ct==0 then return end
		-- 中断效果处理，使之后的破坏和放置指示物处理与特殊召唤视为不同时处理（错时点）
		Duel.BreakEffect()
		-- 向玩家发送选择提示消息：请选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从双方场上选择1至ct张要破坏的卡
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		-- 为被选中的卡显示选择动画并记录这些卡被选择
		Duel.HintSelection(g)
		-- 把选中的卡以效果破坏，返回实际被破坏的卡的数量
		local oc=Duel.Destroy(g,REASON_EFFECT)
		if oc==0 then return end
		e:GetHandler():AddCounter(0x1,oc)
	end
end
-- 无效效果的发动条件：这张卡不在战斗破坏确定状态，且连锁的是魔法·陷阱卡的效果发动
function c3611830.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 检查对方连锁发动的效果是魔法·陷阱卡的效果且该连锁的发动可以被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：判断卡片放置有魔力指示物且可以回到手卡
function c3611830.thfilter(c)
	return c:GetCounter(0x1)>0 and c:IsAbleToHand()
end
-- 无效效果的目标处理：确认自己场上有可以回到手卡的放置了魔力指示物的卡，并设置无效、破坏与回手的操作信息
function c3611830.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张放置有魔力指示物且可以回到手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3611830.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 设置操作信息：宣告此效果将使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若发动的那张卡可以破坏，宣告此效果将破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息：宣告此效果将把场上1张卡回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- 无效效果处理：选自己场上1张有魔力指示物放置的卡回到手卡，使那个发动无效并破坏，之后可以把回手卡数量的魔力指示物给这张卡放置
function c3611830.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择提示消息：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择自己场上1张放置有魔力指示物且可以回到手卡的卡
	local g=Duel.SelectMatchingCard(tp,c3611830.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local count=tc:GetCounter(0x1)
	-- 把选中的卡以效果回到持有者手卡，确认其已在手卡后使该连锁的发动无效
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and Duel.NegateActivation(ev)
		-- 若发动的卡仍与效果相关，则把连锁的魔法·陷阱卡以效果破坏，破坏成功才继续处理
		and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 若这张卡仍与效果相关，询问玩家是否给这张卡放置魔力指示物
		if c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(3611830,2)) then  --"是否放置魔力指示物？"
			-- 中断效果处理，使放置指示物与前面的无效·破坏处理视为不同时处理（错时点）
			Duel.BreakEffect()
			c:AddCounter(0x1,count)
		end
	end
end
-- 抗性条件：这张卡放置有魔力指示物时抗性才适用
function c3611830.ctcon(e)
	return e:GetHandler():GetCounter(0x1)>0
end
-- 离场前连续效果：在这张卡离场前记录其放置的魔力指示物数量，供③效果发动条件判定
function c3611830.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1)
	e:SetLabel(ct)
end
-- ③效果的发动条件：离场前放置有魔力指示物且这张卡是被战斗破坏的
function c3611830.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	return ct>0 and c:IsReason(REASON_BATTLE)
end
-- 过滤函数：判断卡片是可以加入手卡的通常魔法卡
function c3611830.thfilter1(c)
	return c:GetType()==TYPE_SPELL and c:IsAbleToHand()
end
-- ③效果的目标处理：确认卡组存在可以加入手卡的通常魔法卡，并设置检索操作信息
function c3611830.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组是否存在至少1张可以加入手卡的通常魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3611830.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告此效果将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选1张通常魔法卡加入手卡，并让对方确认
function c3611830.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示消息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张可以加入手卡的通常魔法卡
	local g=Duel.SelectMatchingCard(tp,c3611830.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选中的通常魔法卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
