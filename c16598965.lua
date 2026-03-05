--聖邪のステンドグラス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的效果怪兽的种族的以下效果各能适用。
-- ●天使族：自己抽3张。那之后，选2张手卡用喜欢的顺序回到卡组下面。
-- ●恶魔族：对方抽1张。那之后，对方把手卡随机1张丢弃。并且对方在有手卡的场合再选1张丢弃。
function c16598965.initial_effect(c)
	-- 效果描述：选择效果适用
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16598965,0))  --"选择效果适用"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16598965)
	e1:SetTarget(c16598965.target)
	e1:SetOperation(c16598965.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在指定种族且为效果怪兽的正面表示怪兽
function c16598965.filter(c,race)
	return c:IsRace(race) and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 效果发动时点判断：检查是否满足天使族或恶魔族效果的发动条件
function c16598965.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足天使族效果发动条件：场上有天使族效果怪兽且自己可以抽3张卡
	local f1=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FAIRY) and Duel.IsPlayerCanDraw(tp,3)
	-- 判断是否满足恶魔族效果发动条件：场上有恶魔族效果怪兽且对方可以抽1张卡
	local f2=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND) and Duel.IsPlayerCanDraw(1-tp,1)
	if chk==0 then return f1 or f2 end
end
-- 效果发动处理函数：根据选择的效果执行相应的抽卡和手牌处理
function c16598965.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足天使族效果发动条件：场上有天使族效果怪兽且自己可以抽3张卡
	local f1=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FAIRY) and Duel.IsPlayerCanDraw(tp,3)
	-- 判断是否满足恶魔族效果发动条件：场上有恶魔族效果怪兽且对方可以抽1张卡
	local f2=Duel.IsExistingMatchingCard(c16598965.filter,tp,LOCATION_MZONE,0,1,nil,RACE_FIEND) and Duel.IsPlayerCanDraw(1-tp,1)
	local res=false
	-- 若满足天使族效果发动条件且选择使用该效果，则进行抽3张卡操作
	if f1 and (not f2 or Duel.SelectYesNo(tp,aux.Stringid(16598965,1))) and Duel.Draw(tp,3,REASON_EFFECT)==3 then  --"是否让自己抽卡？"
		res=true
		-- 获取玩家手牌中可送回卡组的卡牌组
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
		if g:GetCount()<2 then return end
		-- 将玩家手牌洗切
		Duel.ShuffleHand(tp)
		-- 中断当前效果处理，防止时点错乱
		Duel.BreakEffect()
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选择的卡牌放回卡组底端
		aux.PlaceCardsOnDeckBottom(tp,sg)
	end
	-- 若满足恶魔族效果发动条件且选择使用该效果，则进行对方抽1张卡操作
	if f2 and (not res or Duel.SelectYesNo(tp,aux.Stringid(16598965,2))) and Duel.Draw(1-tp,1,REASON_EFFECT)==1 then  --"是否让对方丢弃手卡？"
		-- 将对方手牌洗切
		Duel.ShuffleHand(1-tp)
		-- 中断当前效果处理，防止时点错乱
		Duel.BreakEffect()
		-- 获取对方手牌组
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		-- 将随机选择的一张对方手牌送去墓地
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
		-- 再次获取对方手牌组
		local g1=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g1==0 then return end
		-- 中断当前效果处理，防止时点错乱
		Duel.BreakEffect()
		-- 让对方随机丢弃1张手牌
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
