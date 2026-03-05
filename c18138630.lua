--魔玩具厄瓶
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「玩具罐」使用。
-- ②：1回合1次，丢弃1张手卡才能发动。自己从卡组抽1张，给双方确认。那是「锋利小鬼」怪兽的场合，可以选场上1张卡破坏。不是的场合，选1张手卡回到卡组最上面或者最下面。
-- ③：这张卡被送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
function c18138630.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 使该卡在场上或墓地时视为「玩具罐」使用
	aux.EnableChangeCode(c,70245411,LOCATION_SZONE+LOCATION_GRAVE)
	-- 1回合1次，丢弃1张手卡才能发动。自己从卡组抽1张，给双方确认。那是「锋利小鬼」怪兽的场合，可以选场上1张卡破坏。不是的场合，选1张手卡回到卡组最上面或者最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18138630,0))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_DESTROY+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCost(c18138630.descost)
	e2:SetTarget(c18138630.destg)
	e2:SetOperation(c18138630.desop)
	c:RegisterEffect(e2)
	-- 这张卡被送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(18138630,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c18138630.atktg)
	e3:SetOperation(c18138630.atkop)
	c:RegisterEffect(e3)
end
-- 检查是否满足丢弃手卡的费用条件
function c18138630.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡的费用
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查是否满足抽卡的条件
function c18138630.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足抽卡的条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡的效果信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置将手卡送回卡组的效果信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND)
end
-- 执行抽卡效果
function c18138630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽卡效果
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取抽卡操作实际操作的卡片
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 向对方确认抽到的卡片
	Duel.ConfirmCards(1-tp,tc)
	if not tc:IsLocation(LOCATION_HAND) then return end
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	if tc:IsSetCard(0xc3) and tc:IsType(TYPE_MONSTER) then
		-- 获取场上所有卡片的集合
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 判断是否选择破坏场上卡片
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(18138630,2)) then  --"是否选场上1张卡破坏？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 显示所选卡片被选为对象
			Duel.HintSelection(sc)
			-- 破坏所选卡片
			Duel.Destroy(sc,REASON_EFFECT)
		end
	else
		-- 获取可送回卡组的手牌集合
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示选择要送回卡组的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 选择将卡片送回卡组顶部或底部
			if Duel.SelectOption(tp,aux.Stringid(18138630,3),aux.Stringid(18138630,4))==0 then  --"卡组最上面/卡组最下面"
				-- 将卡片送回卡组顶部
				Duel.SendtoDeck(sc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将卡片送回卡组底部
				Duel.SendtoDeck(sc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
-- 设置选择对象的效果
function c18138630.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查是否存在可选择的对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 设置攻击力变更效果
function c18138630.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		-- 将对象卡片的攻击力变为原来的一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
