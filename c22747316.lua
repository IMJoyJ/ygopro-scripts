--しっぺ返し
-- 效果：
-- 和自己墓地存在的魔法·陷阱卡同名的卡由对方发动时才能发动。那个发动无效并破坏。那之后，和用这个效果把发动无效的卡同名的卡可以从自己墓地选1张加入手卡。
function c22747316.initial_effect(c)
	-- 以牙还牙效果初始化，设置其为发动时无效连锁、破坏、加入手牌和墓地操作的效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c22747316.condition)
	e1:SetTarget(c22747316.target)
	e1:SetOperation(c22747316.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：对方发动魔法·陷阱卡且该连锁可被无效，并且自己墓地存在同名卡
function c22747316.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动魔法·陷阱卡且该连锁可被无效
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 自己墓地存在同名卡
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,re:GetHandler():GetCode())
end
-- 设置效果处理时的操作信息，包括无效和破坏
function c22747316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤函数，用于筛选可加入手牌的同名卡
function c22747316.filter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果处理函数，使连锁无效并破坏，之后从墓地选卡加入手牌
function c22747316.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=re:GetHandler():GetCode()
	-- 使连锁无效并破坏目标卡，若成功则继续处理后续效果
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 从自己墓地中检索满足条件的同名卡
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c22747316.filter),tp,LOCATION_GRAVE,0,nil,code)
		-- 若存在满足条件的卡且玩家选择发动，则继续处理
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22747316,0)) then  --"是否要选择一张同名卡加入手卡？"
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
