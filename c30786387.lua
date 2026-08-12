--花積み
-- 效果：
-- 「花积」的②的效果1回合只能使用1次。
-- ①：从卡组选「花札卫」怪兽3种类，用喜欢的顺序回到卡组上面。
-- ②：把墓地的这张卡除外，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c30786387.initial_effect(c)
	-- ①：从卡组选「花札卫」怪兽3种类，用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30786387,0))  --"卡片顺序"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30786387.target)
	e1:SetOperation(c30786387.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「花札卫」怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30786387,2))  --"卡片回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30786387)
	-- 效果发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 效果发动费用：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30786387.thtg)
	e2:SetOperation(c30786387.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索卡组中「花札卫」怪兽
function c30786387.filter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER)
end
-- 效果发动时点的处理：判断卡组中是否存在3种类以上的「花札卫」怪兽
function c30786387.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取满足条件的卡组卡片
		local g=Duel.GetMatchingGroup(c30786387.filter,tp,LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>=3
	end
end
-- 效果发动时点的处理：从卡组中选择3种类不同的「花札卫」怪兽并放回卡组顶端
function c30786387.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(c30786387.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		-- 提示玩家选择要放回卡组顶端的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(30786387,1))  --"请选择要放到卡组上面的卡"
		-- 选择3种类不同的卡片组
		local rg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 向对方确认选择的卡片
		Duel.ConfirmCards(1-tp,rg)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		local tg=rg:GetFirst()
		while tg do
			-- 将卡片移至卡组顶端
			Duel.MoveSequence(tg,SEQ_DECKTOP)
			tg=rg:GetNext()
		end
		-- 对卡组最上方3张卡进行排序
		Duel.SortDecktop(tp,tp,3)
	end
end
-- 过滤函数：检索墓地中「花札卫」怪兽并能加入手牌
function c30786387.thfilter(c)
	return c:IsSetCard(0xe6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时点的处理：选择1只墓地中的「花札卫」怪兽作为对象
function c30786387.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30786387.thfilter(chkc) end
	-- 判断是否存在满足条件的墓地目标
	if chk==0 then return Duel.IsExistingTarget(c30786387.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只墓地中的「花札卫」怪兽作为对象
	local sg=Duel.SelectTarget(tp,c30786387.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- 效果发动时点的处理：将目标怪兽加入手牌
function c30786387.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
