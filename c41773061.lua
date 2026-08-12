--Voici la Carte～メニューはこちら～
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把2只卡名不同的「新式魔厨」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。那之后，可以从自己的卡组·墓地选这个效果加入手卡的怪兽种族的1张以下的卡加入手卡。
-- ●兽战士族：「鱼料理的食谱」
-- ●战士族：「肉料理的食谱」
function c41773061.initial_effect(c)
	-- 在卡片上记录「鱼料理的食谱」与「肉料理的食谱」的卡名信息
	aux.AddCodeList(c,87778106,14166715)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把2只卡名不同的「新式魔厨」怪兽给对方观看，对方从那之中选1只。那1只怪兽加入自己手卡，剩余回到卡组。那之后，可以从自己的卡组·墓地选这个效果加入手卡的怪兽种族的1张以下的卡加入手卡。●兽战士族：「鱼料理的食谱」●战士族：「肉料理的食谱」
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,41773061+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41773061.target)
	e1:SetOperation(c41773061.activate)
	c:RegisterEffect(e1)
end
-- 过滤自身卡组的「新式魔厨」怪兽并能加入手牌的过滤条件
function c41773061.filter(c)
	return c:IsSetCard(0x196) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 卡片发动时的效果目标检查与操作信息注册函数
function c41773061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 从卡组中获取所有符合条件的「新式魔厨」怪兽
	local g=Duel.GetMatchingGroup(c41773061.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
	-- 设置将卡组中1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 在卡组或墓地过滤指定卡名且能加入手牌的卡片的过滤条件
function c41773061.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 卡片发动后的效果处理函数，执行观看、选卡加入手牌及后续的食谱卡检索
function c41773061.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组中获取所有符合条件的「新式魔厨」怪兽
	local g=Duel.GetMatchingGroup(c41773061.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 向自己发送“请选择给对方确认的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 在符合条件的怪兽中选择2张卡名不同的怪兽组
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,sg)
	-- 向对方发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tc=sg:Select(1-tp,1,1,nil):GetFirst()
	local code=0
	if tc:IsRace(RACE_BEASTWARRIOR) then code=87778106 end
	if tc:IsRace(RACE_WARRIOR) then code=14166715 end
	-- 从卡组和墓地中获取不受墓地影响且与加入手牌怪兽种族相对应的食谱卡
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41773061.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,code)
	-- 判断选择的怪兽是否成功加入手牌，且该怪兽的种族是兽战士族或战士族
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsRace(RACE_BEASTWARRIOR+RACE_WARRIOR)
		-- 若存在可加入手牌的卡片，则询问玩家是否要将对应的卡加入手牌
		and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(41773061,1)) then  --"是否再选对应的卡加入手卡？"
		-- 中断效果处理，使后续的效果处理与前方不同时进行
		Duel.BreakEffect()
		-- 向自己发送“请选择要加入手牌的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg2=g2:Select(tp,1,1,nil)
		-- 将选中的对应食谱卡加入玩家手牌
		Duel.SendtoHand(sg2,nil,REASON_EFFECT)
		-- 将新加入手牌的卡片给对方玩家确认
		Duel.ConfirmCards(1-tp,sg2)
	end
end
