--黒蠍－強力のゴーグ
-- 效果：
-- 这张卡对对方造成战斗伤害时，可以从下列效果中选择1项发动：
-- ●将对方场上1张怪兽卡弹回对方卡组最上面。
-- ●将对方卡组最上面1张卡送去墓地。
function c48768179.initial_effect(c)
	-- 这张卡对对方造成战斗伤害时，可以从下列效果中选择1项发动：●将对方场上1张怪兽卡弹回对方卡组最上面。●将对方卡组最上面1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48768179,0))  --"选择一个效果发动"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c48768179.condition)
	e1:SetTarget(c48768179.target)
	e1:SetOperation(c48768179.operation)
	c:RegisterEffect(e1)
end
-- 判定本次战斗伤害的承受者为对方（ep≠tp），即本卡对对方造成战斗伤害时才满足诱发条件。
function c48768179.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动前的目标阶段处理：先做合法性检查，确保两个可选效果中至少有一个能执行；同时为后续选择菜单准备条件。
function c48768179.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() end
	-- 在效果发动合法性检查中，判断对方玩家是否能够把卡组最上面1张卡送去墓地（即送墓选项是否可行）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1)
		-- 在效果发动合法性检查中，判断对方场上是否存在1张可以被返回卡组的怪兽卡（即弹回选项是否可行）。
		or Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	local op=0
	-- 向操作玩家发出选择提示，将“选择一个效果发动”的提示信息写入缓存，用于接下来显示选项菜单。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48768179,0))  --"选择一个效果发动"
	-- 检查对方场上是否存在1张可返回卡组的怪兽卡，以确定“弹回对方场上1张怪兽卡”这一选项是否可选。
	if Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil)
		-- 同时检查对方是否能把卡组最上面1张卡送去墓地，以确定“将对方卡组最上面1张卡送去墓地”这一选项是否可选。
		and Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		-- 当两个选项都可用时，弹出选择菜单让玩家选择发动哪个效果，返回的序号存入op（0为弹回怪兽，1为送墓）。
		op=Duel.SelectOption(tp,aux.Stringid(48768179,1),aux.Stringid(48768179,2))  --"将对方场上1张怪兽卡弹回对方牌组最上面。/将对方牌组最上面1张卡送去墓地。"
	-- 如果送墓选项可用而弹回选项不可用，则进入只能选择送墓的分支。
	elseif Duel.IsPlayerCanDiscardDeck(1-tp,1) then
		-- 因为只有送墓选项可用，直接调用SelectOption让玩家确认该选项，并将op设为1。
		Duel.SelectOption(tp,aux.Stringid(48768179,2))  --"将对方牌组最上面1张卡送去墓地。"
		op=1
	else
		-- 因为只有弹回选项可用，直接调用SelectOption让玩家确认该选项，并将op设为0。
		Duel.SelectOption(tp,aux.Stringid(48768179,1))  --"将对方场上1张怪兽卡弹回对方牌组最上面。"
		op=0
	end
	e:SetLabel(op)
	if op==0 then
		-- 选择“弹回怪兽”后，向玩家发出“请选择要返回卡组的卡”的提示，将选择目标卡片的提示信息写入缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从对方场上主要怪兽区选择1张可返回卡组的怪兽卡作为效果处理时的对象，同时将该卡登记为当前连锁的对象。
		local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
		-- 设置本次连锁的操作信息：把选中的对象卡返回卡组（CATEGORY_TODECK），数量为1。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else
		-- 设置本次连锁的操作信息：将对方卡组最上面1张卡送去墓地（CATEGORY_DECKDES），数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
		e:SetProperty(0)
	end
end
-- 效果处理函数：根据之前在target中选择的选项实际执行对应处理；若选项为0则弹回对象怪兽，否则舍弃对方卡组顶端1张。
function c48768179.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 取得效果处理时与本次连锁关联的对象卡（即之前选择的对方场上怪兽）。
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将该对象卡弹回其持有者卡组的最顶端（SEQ_DECKTOP表示卡组最上面）。
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
	else
		-- 将对方卡组最上面1张卡送去墓地。
		Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
	end
end
