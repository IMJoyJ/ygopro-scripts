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
	-- 为该卡注册在魔法陷阱区与墓地时卡名视为「玩具罐」（70245411）的效果。
	aux.EnableChangeCode(c,70245411,LOCATION_SZONE+LOCATION_GRAVE)
	-- ②：1回合1次，丢弃1张手卡才能发动。自己从卡组抽1张，给双方确认。那是「锋利小鬼」怪兽的场合，可以选场上1张卡破坏。不是的场合，选1张手卡回到卡组最上面或者最下面。
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
	-- ③：这张卡被送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
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
-- 效果②的代价函数：在发动前检查是否能从手牌丢弃1张卡作为代价，发动时执行丢弃操作。
function c18138630.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法时检查是否存在1张可从手牌丢弃的卡（不含本卡自身）作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手牌选择并丢弃1张卡，理由为代价+丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果②的发动目标/条件判断函数：确认可以抽卡，并设置抽卡及回卡组的操作信息。
function c18138630.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否能抽1张卡，作为效果发动的条件。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：本次效果将进行1次抽卡，目标玩家为自己，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息：本次效果可能将手牌返回卡组，目标位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND)
end
-- 效果②的实际处理：抽1张卡并展示，若抽到「锋利小鬼」怪兽则可破坏场上1张卡，否则选1张手卡返回卡组顶或底。
function c18138630.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽1张卡；若没有实际抽到卡则中止后续处理。
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 取得刚才抽卡操作实际抽到的那张卡。
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	if not tc:IsLocation(LOCATION_HAND) then return end
	-- 确认后洗切手牌，避免暴露手牌顺序。
	Duel.ShuffleHand(tp)
	if tc:IsSetCard(0xc3) and tc:IsType(TYPE_MONSTER) then
		-- 取得场上所有卡（双方怪兽区和魔陷区）作为可能被破坏的候选集合。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 若场上有卡且玩家选择发动破坏，则继续破坏处理。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(18138630,2)) then  --"是否选场上1张卡破坏？"
			-- 中断当前效果处理，使破坏行为与之前的抽卡确认分开，避免错时点。
			Duel.BreakEffect()
			-- 发送选择卡片提示，要求玩家选择要破坏的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 高亮显示选择的卡并播放选择动画，同时记录该卡被选为对象。
			Duel.HintSelection(sc)
			-- 将选择的卡以效果破坏并送去墓地。
			Duel.Destroy(sc,REASON_EFFECT)
		end
	else
		-- 取得自己手牌中所有能返回卡组的卡作为候选集合。
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使回卡组行为与之前的抽卡确认分开，避免错时点。
			Duel.BreakEffect()
			-- 发送选择卡片提示，要求玩家选择要返回卡组的手牌。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			local sc=g:Select(tp,1,1,nil)
			-- 让玩家选择返回卡组最上面或最下面，0表示最上面。
			if Duel.SelectOption(tp,aux.Stringid(18138630,3),aux.Stringid(18138630,4))==0 then  --"卡组最上面/卡组最下面"
				-- 将选择的卡返回持有者卡组最顶端。
				Duel.SendtoDeck(sc,nil,SEQ_DECKTOP,REASON_EFFECT)
			else
				-- 将选择的卡返回持有者卡组最底端。
				Duel.SendtoDeck(sc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			end
		end
	end
end
-- 效果③的发动条件与对象选择函数：选择对方场上1只表侧表示怪兽为对象，且需可被取对象。
function c18138630.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方怪兽区是否存在1只表侧表示怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送选择提示消息，要求玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从对方怪兽区选择1只表侧表示怪兽为对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果③的处理：将对象怪兽的攻击力变成原本攻击力的一半直到回合结束。
function c18138630.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果③选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		-- 那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
