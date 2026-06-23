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
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：把自己场上6个魔力指示物取除才能发动。灵摆区域的这张卡特殊召唤。那之后，选最多有自己场上的可以放置魔力指示物的卡数量的场上的卡破坏，破坏数量的魔力指示物给这张卡放置。
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
	-- ②：有魔力指示物放置的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c3611830.ctcon)
	-- 设置效果值为过滤函数aux.tgoval，用于判断该卡是否不会成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：有魔力指示物放置的这张卡不会成为对方的效果的对象，不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c3611830.ctcon)
	-- 设置效果值为过滤函数aux.indoval，用于判断该卡是否不会被对方效果破坏
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- ③：有魔力指示物放置的这张卡被战斗破坏时才能发动。从卡组把1张通常魔法卡加入手卡。
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
-- 检查玩家是否可以移除6个魔力指示物作为发动cost
function c3611830.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以移除6个魔力指示物作为发动cost
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,6,REASON_COST) end
	-- 从玩家场上移除6个魔力指示物作为发动cost
	Duel.RemoveCounter(tp,1,0,0x1,6,REASON_COST)
end
-- 过滤函数，用于判断卡是否可以放置魔力指示物
function c3611830.cfilter(c)
	return c:IsCanHaveCounter(0x1)
end
-- 设置发动时的条件，检查玩家是否可以特殊召唤此卡并添加魔力指示物
function c3611830.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否可以特殊召唤此卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家是否可以向此卡添加魔力指示物
		and Duel.IsCanAddCounter(tp,0x1,1,c) end
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，表示将要破坏场上卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理灵摆效果的发动操作，包括特殊召唤、破坏场上卡并放置魔力指示物
function c3611830.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取场上可以放置魔力指示物的卡的数量
		local ct=Duel.GetMatchingGroupCount(c3611830.cfilter,tp,LOCATION_ONFIELD,0,nil)
		if ct==0 then return end
		-- 中断当前效果处理，使之后的效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上最多与可放置魔力指示物的卡数量相等的卡进行破坏
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		-- 显示被选为对象的卡
		Duel.HintSelection(g)
		-- 破坏选中的卡
		local oc=Duel.Destroy(g,REASON_EFFECT)
		if oc==0 then return end
		e:GetHandler():AddCounter(0x1,oc)
	end
end
-- 判断是否可以无效对方的魔法或陷阱卡效果
function c3611830.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断对方发动的卡是否为魔法或陷阱类型且可以被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于判断卡是否具有魔力指示物且可以返回手牌
function c3611830.thfilter(c)
	return c:GetCounter(0x1)>0 and c:IsAbleToHand()
end
-- 设置发动时的处理信息，包括无效对方效果、破坏对方卡和将卡返回手牌
function c3611830.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在有魔力指示物的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3611830.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 设置操作信息，表示将要无效对方效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将要破坏对方卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置操作信息，表示将要将卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- 处理怪兽效果的发动操作，包括将卡返回手牌、无效对方效果、破坏对方卡并放置魔力指示物
function c3611830.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上一张有魔力指示物的卡返回手牌
	local g=Duel.SelectMatchingCard(tp,c3611830.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local count=tc:GetCounter(0x1)
	-- 将卡返回手牌并确认其在手牌中
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and Duel.NegateActivation(ev)
		-- 无效对方效果并破坏对方卡
		and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 询问玩家是否放置魔力指示物
		if c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(3611830,2)) then  --"是否放置魔力指示物？"
			-- 中断当前效果处理，使之后的效果视为错时处理
			Duel.BreakEffect()
			c:AddCounter(0x1,count)
		end
	end
end
-- 判断此卡是否具有魔力指示物
function c3611830.ctcon(e)
	return e:GetHandler():GetCounter(0x1)>0
end
-- 记录此卡的魔力指示物数量
function c3611830.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1)
	e:SetLabel(ct)
end
-- 判断此卡是否被战斗破坏且具有魔力指示物
function c3611830.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	return ct>0 and c:IsReason(REASON_BATTLE)
end
-- 过滤函数，用于判断卡是否为通常魔法卡
function c3611830.thfilter1(c)
	return c:GetType()==TYPE_SPELL and c:IsAbleToHand()
end
-- 设置发动时的处理信息，表示将要从卡组检索通常魔法卡
function c3611830.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否存在通常魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3611830.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理怪兽效果的发动操作，包括从卡组检索通常魔法卡并加入手牌
function c3611830.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张通常魔法卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c3611830.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
