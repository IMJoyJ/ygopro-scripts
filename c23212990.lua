--六武式風雷斬
-- 效果：
-- 把自己场上的1个武士道指示物取除，从以下效果选择1个发动。
-- ●选择对方场上存在的1只怪兽破坏。
-- ●选择对方场上存在的1张卡回到手卡。
function c23212990.initial_effect(c)
	-- 把自己场上的1个武士道指示物取除，从以下效果选择1个发动。●选择对方场上存在的1只怪兽破坏。●选择对方场上存在的1张卡回到手卡。
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
c23212990.mentioned_counter={
	[0x3]=true,
}
-- 发动的代价：将自己场上的1个武士道指示物取除
function c23212990.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己场上存在可以作为代价取除的1个武士道指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,1,REASON_COST) end
	-- 实际执行代价：将自己场上的1个武士道指示物取除
	Duel.RemoveCounter(tp,1,0,0x3,1,REASON_COST)
end
-- 对象与发动条件检查：对象限定为场上存在的卡，并检查对方场上是否存在可破坏的怪兽或可回到手卡的卡
function c23212990.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：确认对方场上存在1只以上可以成为效果对象的怪兽（用于破坏效果）
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
		-- 或者确认对方场上存在1张以上可以回到手卡并成为效果对象的卡（用于回手效果），满足任一即可发动
		or Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 记录对方场上是否存在可选择的怪兽，作为破坏效果选项是否可用的判定
	local b1=Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	-- 记录对方场上是否存在可以回到手卡的卡，作为回手效果选项是否可用的判定
	local b2=Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	local op=0
	-- 向玩家提示「请选择要发动的效果」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 两个效果都可用时，让玩家在「破坏对方1只怪兽」和「将对方1张卡回到手卡」两个选项中选择1个
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(23212990,0),aux.Stringid(23212990,1))  --"对方场上存在的1只怪兽破坏。/对方场上存在的1张卡回到手牌。"
	-- 只有破坏效果可用时，玩家只能选择「破坏对方1只怪兽」
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(23212990,0))  --"对方场上存在的1只怪兽破坏。"
	-- 只有回手效果可用时，玩家只能选择「将对方1张卡回到手卡」，并将选项序号调整为1
	else op=Duel.SelectOption(tp,aux.Stringid(23212990,1))+1 end  --"对方场上存在的1张卡回到手牌。"
	e:SetLabel(op)
	if op==0 then
		-- 向玩家提示「请选择要破坏的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上存在的1只怪兽作为破坏效果的对象
		local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置连锁的操作信息：本次连锁确定要破坏1张作为对象的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		-- 向玩家提示「请选择要返回手牌的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上存在的1张可以回到手卡的卡作为回手效果的对象
		local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置连锁的操作信息：本次连锁确定要让1张作为对象的卡回到手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果处理：根据之前选择的选项，将对象怪兽破坏或将对象卡回到持有者的手卡
function c23212990.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if e:GetLabel()==0 then
			-- 以效果原因将作为对象的对方怪兽破坏
			Duel.Destroy(tc,REASON_EFFECT)
		else
			-- 以效果原因将作为对象的对方卡回到持有者的手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
