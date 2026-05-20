--オールド・マインド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把对方手卡随机1张确认。那之后，从以下效果选1个适用。
-- ●和确认的卡相同种类（怪兽·魔法·陷阱）的自己手卡1张卡和确认的对方的卡丢弃。那之后，场上的这张卡加入对方手卡，自己从卡组抽1张。
-- ●自己失去1000基本分。
function c54239282.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把对方手卡随机1张确认。那之后，从以下效果选1个适用。●和确认的卡相同种类（怪兽·魔法·陷阱）的自己手卡1张卡和确认的对方的卡丢弃。那之后，场上的这张卡加入对方手卡，自己从卡组抽1张。●自己失去1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,54239282+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c54239282.target)
	e1:SetOperation(c54239282.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的Target函数，用于检测发动条件
function c54239282.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
end
-- 定义过滤函数，筛选自己手卡中与确认的卡相同种类且可以被效果丢弃的卡
function c54239282.filter(c,type)
	return c:IsType(type) and c:IsDiscardable(REASON_EFFECT)
end
-- 定义卡片发动的Operation函数，执行确认对方手卡并选择适用效果的处理
function c54239282.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若对方手卡数量为0则不处理
	if Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)==0 then return end
	-- 随机选择对方的1张手卡
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):RandomSelect(tp,1)
	local tc=g:GetFirst()
	-- 给发动玩家确认选中的对方手卡
	Duel.ConfirmCards(tp,tc)
	local type=bit.band(tc:GetType(),0x7)
	local c=e:GetHandler()
	-- 获取自己手卡中与确认的卡相同种类的卡片组
	local g=Duel.GetMatchingGroup(c54239282.filter,tp,LOCATION_HAND,0,nil,type)
	local op=0
	-- 检查是否满足第一个效果的适用条件（自己有同种类手卡可丢弃、对方确认的卡可丢弃、此卡在场且能送去对方手卡、自己能抽卡）
	if g:GetCount()>0 and tc:IsDiscardable(REASON_EFFECT) and c:IsRelateToEffect(e) and c:GetLeaveFieldDest()==0 and Duel.IsPlayerCanDraw(tp,1) then
		-- 让玩家从“丢弃手卡并抽卡”和“失去基本分”中选择一个适用
		op=Duel.SelectOption(tp,aux.Stringid(54239282,0),aux.Stringid(54239282,1))  --"丢弃手卡/失去基本分"
	else
		-- 若不满足第一个效果的条件，则强制选择第二个效果（失去基本分）
		op=Duel.SelectOption(tp,aux.Stringid(54239282,1))+1  --"失去基本分"
	end
	if op==0 then
		-- 中断当前效果，使后续的丢弃处理与确认手卡不视为同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		local sg=g:Select(tp,1,1,nil)
		sg:AddCard(tc)
		-- 将自己和对方的卡丢弃送去墓地，并检查此卡是否仍在场上
		if Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)~=0 and c:IsRelateToEffect(e) then
			-- 中断当前效果，使后续的加入手卡和抽卡处理与丢弃不视为同时处理
			Duel.BreakEffect()
			c:CancelToGrave()
			-- 将场上的这张卡加入对方手卡，并检查是否成功
			if Duel.SendtoHand(c,1-tp,REASON_EFFECT)~=0 then
				-- 自己从卡组抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	else
		-- 中断当前效果，使后续的失去基本分处理与确认手卡不视为同时处理
		Duel.BreakEffect()
		-- 使自己失去1000基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-1000)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
