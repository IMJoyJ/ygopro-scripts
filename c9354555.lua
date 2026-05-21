--フォトン・ベール
-- 效果：
-- 从自己手卡让3只光属性怪兽回到卡组，可以从自己卡组把最多3只光属性·4星以下的怪兽加入手卡。2只以上加入手卡的场合，必须全部是同名怪兽。
function c9354555.initial_effect(c)
	-- 从自己手卡让3只光属性怪兽回到卡组，可以从自己卡组把最多3只光属性·4星以下的怪兽加入手卡。2只以上加入手卡的场合，必须全部是同名怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9354555.target)
	e1:SetOperation(c9354555.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以回到卡组的光属性怪兽
function c9354555.filter1(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 过滤卡组中可以加入手牌的4星以下的光属性怪兽
function c9354555.filter2(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置
function c9354555.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少3只可以回到卡组的光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9354555.filter1,tp,LOCATION_HAND,0,3,nil)
		-- 检查卡组中是否存在至少1只可以加入手牌的4星以下的光属性怪兽
		and Duel.IsExistingMatchingCard(c9354555.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果会使手牌的3张卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_HAND)
	-- 设置操作信息，表示此效果会从卡组将至少1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c9354555.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中所有可以回到卡组的光属性怪兽
	local g=Duel.GetMatchingGroup(c9354555.filter1,tp,LOCATION_HAND,0,nil)
	if g:GetCount()<3 then return end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local dg=g:Select(tp,3,3,nil)
	-- 给对方玩家确认要返回卡组的卡
	Duel.ConfirmCards(1-tp,dg)
	-- 将选中的卡送回卡组并洗牌
	Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取卡组中所有可以加入手牌的4星以下的光属性怪兽
	local sg=Duel.GetMatchingGroup(c9354555.filter2,tp,LOCATION_DECK,0,nil)
	if sg:GetCount()==0 then return end
	-- 中断当前效果处理，使后续的检索手牌处理不与回卡组同时进行
	Duel.BreakEffect()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local hg=sg:Select(tp,1,1,nil)
	sg:RemoveCard(hg:GetFirst())
	sg=sg:Filter(Card.IsCode,nil,hg:GetFirst():GetCode())
	-- 如果卡组中还有同名卡，询问玩家是否继续将同名卡加入手牌
	if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(9354555,0)) then  --"是否还要加入手卡？"
		-- 提示玩家选择要加入手牌的同名卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tg=sg:Select(tp,1,2,nil)
		hg:Merge(tg)
	end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(hg,nil,REASON_EFFECT)
	-- 给对方玩家确认加入手牌的卡
	Duel.ConfirmCards(1-tp,hg)
end
