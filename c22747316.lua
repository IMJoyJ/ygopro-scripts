--しっぺ返し
-- 效果：
-- 和自己墓地存在的魔法·陷阱卡同名的卡由对方发动时才能发动。那个发动无效并破坏。那之后，和用这个效果把发动无效的卡同名的卡可以从自己墓地选1张加入手卡。
function c22747316.initial_effect(c)
	-- 和自己墓地存在的魔法·陷阱卡同名的卡由对方发动时才能发动。那个发动无效并破坏。那之后，和用这个效果把发动无效的卡同名的卡可以从自己墓地选1张加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c22747316.condition)
	e1:SetTarget(c22747316.target)
	e1:SetOperation(c22747316.activate)
	c:RegisterEffect(e1)
end
-- 该效果为诱发即时效果，满足条件时在对方发动魔法·陷阱卡且该发动可以被无效，同时自己墓地存在与所发动卡同名的卡时，才允许发动。
function c22747316.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动者为对方玩家，且对方发动的效果是魔法·陷阱卡的发动，并且该连锁的发动可以被无效。
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 判定自己墓地存在至少1张与对方发动的卡片当前卡号相同的魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,re:GetHandler():GetCode())
end
-- 发动时的目标处理：声明本效果将无效那次发动，并视情况将那次发动的卡列入破坏的对象，同时设置相应操作信息。
function c22747316.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为‘把那次发动无效’，对象为正在发动的连锁（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动的那张卡仍与发动效果相关联，则额外设置操作信息为“破坏该卡”，使破坏效果也被记录在案。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤函数：选择墓地中卡号与指定代码相同且能够加入手卡的卡。
function c22747316.filter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果处理阶段：先无效并破坏对方发动的卡，若成功，则从墓地选择一张同名卡加入手卡，并向对方确认。
function c22747316.activate(e,tp,eg,ep,ev,re,r,rp)
	local code=re:GetHandler():GetCode()
	-- 效果处理成功的条件判断：对方那次发动被成功无效，且对方发动的那张卡仍在场上与效果关联，同时该卡被成功破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 检索自己墓地中满足同名且可加入手卡，并且不受王家长眠之谷等墓地效果影响的卡，作为可加入手卡的候选组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c22747316.filter),tp,LOCATION_GRAVE,0,nil,code)
		-- 若存在可选的同名卡，且玩家确认要选择一张加入手卡，则继续后续处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(22747316,0)) then  --"是否要选择一张同名卡加入手卡？"
			-- 中断当前效果处理，使后续加入手卡的处理与之前的无效、破坏处理视为不同时处理，避免产生错误时点。
			Duel.BreakEffect()
			-- 向玩家显示“请选择要加入手牌的卡”的选择提示，并进入选卡界面。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将玩家选中的那张卡加入其持有者的手卡，引起加入手卡的效果处理。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示本次加入手卡的卡片，确认加入手卡的结果。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
