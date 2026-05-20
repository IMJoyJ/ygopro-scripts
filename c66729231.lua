--イビリチュア・ジールギガス
-- 效果：
-- 名字带有「遗式」的仪式魔法卡降临。1回合1次，支付1000基本分才能发动。从卡组抽1张卡，给双方确认。确认的卡是名字带有「遗式」的怪兽的场合，场上1张卡回到持有者卡组。
function c66729231.initial_effect(c)
	c:EnableReviveLimit()
	-- 1回合1次，支付1000基本分才能发动。从卡组抽1张卡，给双方确认。确认的卡是名字带有「遗式」的怪兽的场合，场上1张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66729231,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c66729231.cost)
	e1:SetTarget(c66729231.target)
	e1:SetOperation(c66729231.operation)
	c:RegisterEffect(e1)
end
-- 支付1000基本分的发动代价（Cost）处理
function c66729231.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能够支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000点基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 抽卡效果的发动准备与目标确认（Target）处理
function c66729231.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否具有抽1张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的操作信息，声明此效果包含抽卡分类，预计抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡、确认卡片以及后续让场上卡片返回卡组的效果处理（Operation）
function c66729231.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行抽1张卡的操作，若未能成功抽卡则不进行后续处理
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取刚才通过抽卡操作加入手牌的那张卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	-- 将抽到的卡展示给对方玩家确认
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsSetCard(0x3a) and tc:IsType(TYPE_MONSTER) then
		-- 在客户端显示“请选择要返回卡组的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让发动效果的玩家从双方场上选择1张可以返回卡组的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		-- 将选中的卡片送回持有者卡组并洗牌
		Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	-- 洗切发动效果玩家的手牌
	Duel.ShuffleHand(tp)
end
