--六武式風雷斬
-- 效果：
-- 把自己场上的1个武士道指示物取除，从以下效果选择1个发动。
-- ●选择对方场上存在的1只怪兽破坏。
-- ●选择对方场上存在的1张卡回到手卡。
function c23212990.initial_effect(c)
	-- 效果原文内容：把自己场上的1个武士道指示物取除，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c23212990.cost)
	e1:SetTarget(c23212990.target)
	e1:SetOperation(c23212990.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：支付1个武士道指示物作为费用
function c23212990.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查是否可以移除1个武士道指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,1,REASON_COST) end
	-- 规则层面操作：移除1个武士道指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x3,1,REASON_COST)
end
-- 规则层面操作：设置选择目标的条件，检查对方场上是否存在怪兽或卡
function c23212990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 规则层面操作：检查对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 规则层面操作：检查对方场上是否存在可送回手牌的卡
		or Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 规则层面操作：检查对方场上是否存在怪兽
	local b1=Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 规则层面操作：检查对方场上是否存在可送回手牌的卡
	local b2=Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	local op=0
	-- 规则层面操作：提示玩家选择发动的效果
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 规则层面操作：当两种效果都可用时，让玩家选择其中一种
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(23212990,0),aux.Stringid(23212990,1))  --"对方场上存在的1只怪兽破坏。/对方场上存在的1张卡回到手牌。"
	-- 规则层面操作：当只有破坏效果可用时，让玩家选择该效果
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(23212990,0))  --"对方场上存在的1只怪兽破坏。"
	-- 规则层面操作：当只有回手牌效果可用时，让玩家选择该效果
	else op=Duel.SelectOption(tp,aux.Stringid(23212990,1))+1 end  --"对方场上存在的1张卡回到手牌。"
	e:SetLabel(op)
	if op==0 then
		-- 规则层面操作：提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 规则层面操作：选择对方场上1只怪兽作为破坏对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		-- 规则层面操作：设置连锁操作信息，标记将要破坏的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		-- 规则层面操作：提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 规则层面操作：选择对方场上1张卡作为回手牌对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 规则层面操作：设置连锁操作信息，标记将要返回手牌的卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果原文内容：●选择对方场上存在的1只怪兽破坏。●选择对方场上存在的1张卡回到手卡。
function c23212990.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if e:GetLabel()==0 then
			-- 规则层面操作：将目标怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		else
			-- 规则层面操作：将目标卡送回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
