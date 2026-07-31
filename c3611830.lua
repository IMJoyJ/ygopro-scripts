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
	-- 为灵摆怪兽c添加灵摆怪兽属性，使其可进行灵摆召唤和灵摆卡的发动
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
	-- 设置该怪兽不会成为对方的卡的效果对象的过滤函数（使用aux.tgoval）
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：有魔力指示物放置的这张卡被战斗破坏时才能发动。从卡组把1张通常魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c3611830.ctcon)
	-- 设置该怪兽不会被对方的卡的效果破坏的过滤函数（使用aux.indoval）
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	-- 记录效果：用于在怪兽离开灵摆区时将其上的魔力指示物数量保存到e5的Label中，供战斗破坏效果使用
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
-- 效果cost：把自己场上6个魔力指示物取除才能发动
function c3611830.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有足够的6个魔力指示物可以移除
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,6,REASON_COST) end
	-- 移除玩家场上的6个魔力指示物作为cost
	Duel.RemoveCounter(tp,1,0,0x1,6,REASON_COST)
end
-- 过滤函数：检查卡是否可放置魔力指示物
function c3611830.cfilter(c)
	return c:IsCanHaveCounter(0x1)
end
-- 灵摆效果的目标设置：检查特殊召唤和放置指示物的条件是否满足
function c3611830.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家灵摆区有位置且该卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家能否向该卡放置1个魔力指示物
		and Duel.IsCanAddCounter(tp,0x1,1,c) end
	-- 获取场上所有卡（用于破坏选择）
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏操作的信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置特殊召唤操作的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果的处理效果：特殊召唤并破坏卡放置指示物
function c3611830.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果该卡与效果关联且成功特殊召唤则继续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取场上可放置魔力指示物的卡的数量
		local ct=Duel.GetMatchingGroupCount(c3611830.cfilter,tp,LOCATION_ONFIELD,0,nil)
		if ct==0 then return end
		-- 中断当前效果以进行新的效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择1到ct张场上的卡进行破坏
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
		-- 显示被选中的卡
		Duel.HintSelection(g)
		-- 破坏选中的卡
		local oc=Duel.Destroy(g,REASON_EFFECT)
		if oc==0 then return end
		e:GetHandler():AddCounter(0x1,oc)
	end
end
-- 怪兽效果1的发动条件函数
function c3611830.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 返回是否为魔法陷阱卡发动且该连锁可以无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数：检查场上的卡是否有魔力指示物且可返回手卡
function c3611830.thfilter(c)
	return c:GetCounter(0x1)>0 and c:IsAbleToHand()
end
-- 怪兽效果1的目标设置函数
function c3611830.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在有魔力指示物且可返回手卡的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3611830.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 设置无效化操作的信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏操作的信息（针对被无效的卡）
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	-- 设置返回手卡操作的信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
-- 怪兽效果1的处理效果：无效并破坏，选择是否放置指示物
function c3611830.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择1张有魔力指示物的卡返回手牌
	local g=Duel.SelectMatchingCard(tp,c3611830.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	local count=tc:GetCounter(0x1)
	-- 将选中的卡返回手牌并检查是否成功
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and Duel.NegateActivation(ev)
		-- 如果成功返回手牌且无效和破坏都成功则继续
		and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0 then
		-- 如果玩家选择是则放置魔力指示物
		if c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(3611830,2)) then  --"是否放置魔力指示物？"
			-- 中断当前效果
			Duel.BreakEffect()
			c:AddCounter(0x1,count)
		end
	end
end
-- 条件函数：检查该卡上是否有魔力指示物
function c3611830.ctcon(e)
	return e:GetHandler():GetCounter(0x1)>0
end
-- 记录效果：将当前魔力指示物数量保存到e5的Label中
function c3611830.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1)
	e:SetLabel(ct)
end
-- 条件函数：检查记录的指示物数量大于0且因战斗被破坏
function c3611830.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	return ct>0 and c:IsReason(REASON_BATTLE)
end
-- 过滤函数：检查卡是否为通常魔法卡且可加入手牌
function c3611830.thfilter1(c)
	return c:GetType()==TYPE_SPELL and c:IsAbleToHand()
end
-- 检索效果的目标设置函数
function c3611830.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查卡组中是否有通常魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3611830.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌操作的信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理效果：从卡组检索通常魔法卡加入手牌
function c3611830.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张通常魔法卡
	local g=Duel.SelectMatchingCard(tp,c3611830.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对手确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
