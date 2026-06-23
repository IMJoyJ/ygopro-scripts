--聖邪のステンドグラス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的效果怪兽的种族的以下效果各能适用。
-- ●天使族：自己抽3张。那之后，选2张手卡用喜欢的顺序回到卡组下面。
-- ●恶魔族：对方抽1张。那之后，对方把手卡随机1张丢弃。并且对方在有手卡的场合再选1张丢弃。
function c16598965.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的效果怪兽的种族的以下效果各能适用。●天使族：自己抽3张。那之后，选2张手卡用喜欢的顺序回到卡组下面。●恶魔族：对方抽1张。那之后，对方把手卡随机1张丢弃。并且对方在有手卡的场合再选1张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16598965,0))  --"选择效果适用"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16598965)
	e1:SetTarget(c16598965.target)
	e1:SetOperation(c16598965.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上特定种族的表侧表示的效果怪兽
function c16598965.filter(c,race)
	return c:IsRace(race) and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果发动时的可行性检查（检查场上是否有符合条件效果的怪兽且对应玩家能抽卡）
function c16598965.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在天使族的效果怪兽且自己可以抽卡
	local f1=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FAIRY) and Duel.IsPlayerCanDraw(tp,3)
	-- 检查自己场上是否存在恶魔族的效果怪兽且对方可以抽卡
	local f2=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND) and Duel.IsPlayerCanDraw(1-tp,1)
	if chk==0 then return f1 or f2 end
end
-- 效果处理的执行，根据场上怪兽的种族依次适用效果
function c16598965.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在天使族的效果怪兽且自己可以抽卡
	local f1=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FAIRY) and Duel.IsPlayerCanDraw(tp,3)
	-- 判断自己场上是否存在恶魔族的效果怪兽且对方可以抽卡
	local f2=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND) and Duel.IsPlayerCanDraw(1-tp,1)
	local res=false
	-- 如果满足天使族效果适用条件且玩家选择适用，则自己抽3张卡
	if f1 and (not f2 or Duel.SelectYesNo(tp,aux.Stringid(16598965,1))) and Duel.Draw(tp,3,REASON_EFFECT)==3 then  --"是否让自己抽卡？"
		res=true
		-- 获取自己手卡中可以放回卡组的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
		if g:GetCount()<2 then return end
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 中断效果，使之后的处理与抽卡不同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2张手卡放回卡组最下方
		aux.PlaceCardsOnDeckBottom(tp,sg)
	end
	-- 如果满足恶魔族效果适用条件且玩家选择适用，则对方抽1张卡
	if f2 and (not res or Duel.SelectYesNo(tp,aux.Stringid(16598965,2))) and Duel.Draw(1-tp,1,REASON_EFFECT)==1 then  --"是否让对方丢弃手卡？"
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
		-- 中断效果，使之后的处理与抽卡不同时进行
		Duel.BreakEffect()
		-- 获取对方的手卡
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		-- 将对方随机选择的1张手卡送去墓地（丢弃）
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
		-- 再次获取对方当前的手卡
		local g1=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g1==0 then return end
		-- 中断效果，使之后的处理与前一次丢弃不同时进行
		Duel.BreakEffect()
		-- 对方选择自己的一张手卡丢弃
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
