--Voici la Carte～メニューはこちら～
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把2只卡名不同的「新式魔厨」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。那之后，可以从自己的卡组·墓地选这个效果加入手卡的怪兽种族的1张以下的卡加入手卡。
-- ●兽战士族：「鱼料理的食谱」
-- ●战士族：「肉料理的食谱」
function c41773061.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,41773061+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41773061.target)
	e1:SetOperation(c41773061.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「新式魔厨」怪兽
function c41773061.filter(c)
	return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果作用：判断是否满足发动条件
function c41773061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的「新式魔厨」怪兽
	local g=Duel.GetMatchingGroup(c41773061.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
	-- 设置连锁操作信息为检索卡组
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索满足条件的指定卡号的卡
function c41773061.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 效果作用：发动效果
function c41773061.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的「新式魔厨」怪兽
	local g=Duel.GetMatchingGroup(c41773061.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择2只卡名不同的「新式魔厨」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 向对方确认选择的卡
	Duel.ConfirmCards(1-tp,sg)
	-- 提示对方选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tc=sg:Select(1-tp,1,1,nil):GetFirst()
	local code=0
	if tc:IsRace(RACE_BEASTWARRIOR) then code=87778106 end
	if tc:IsRace(RACE_WARRIOR) then code=14166715 end
	-- 检索满足条件的对应种族的卡
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41773061.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,code)
	-- 将选中的怪兽加入手牌
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsRace(RACE_BEASTWARRIOR+RACE_WARRIOR)
		-- 询问是否再选一张卡加入手牌
		and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(41773061,1)) then  --"是否再选对应的卡加入手卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		-- 向对方确认选择的卡
		Duel.ConfirmCards(1-tp,sg2)
	end
end
