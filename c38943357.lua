--魔力統轄
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1张「恩底弥翁」卡加入手卡。那之后，可以给自己场上的可以放置魔力指示物的卡尽可能放置最多有自己的场上·墓地的「魔力统辖」「魔力掌握」数量的魔力指示物。
function c38943357.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,38943357+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38943357.target)
	e1:SetOperation(c38943357.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤出卡组中可以加入手牌的「恩底弥翁」卡
function c38943357.filter(c)
	return c:IsSetCard(0x12a) and c:IsAbleToHand()
end
-- 效果作用：设置连锁处理时的OperationInfo，用于检索满足条件的「恩底弥翁」卡
function c38943357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即卡组中是否存在至少1张「恩底弥翁」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38943357.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁处理时的OperationInfo，用于检索满足条件的「恩底弥翁」卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：过滤出自己场上或墓地的「魔力统辖」或「魔力掌握」卡
function c38943357.cfilter(c)
	return c:IsCode(38943357,75014062) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果作用：从卡组检索1张「恩底弥翁」卡加入手牌，并询问是否放置魔力指示物
function c38943357.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的「恩底弥翁」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：选择满足条件的1张「恩底弥翁」卡
	local g=Duel.SelectMatchingCard(tp,c38943357.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 效果作用：将选中的「恩底弥翁」卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 效果作用：确认玩家手牌中加入的「恩底弥翁」卡
		Duel.ConfirmCards(1-tp,g)
		-- 效果作用：统计自己场上和墓地的「魔力统辖」或「魔力掌握」卡数量
		local ct=Duel.GetMatchingGroupCount(c38943357.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
		-- 效果作用：判断自己场上是否存在可以放置魔力指示物的卡
		if ct>0 and Duel.GetMatchingGroupCount(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,nil,0x1,1)>0
			-- 效果作用：询问玩家是否要在场上放置魔力指示物
			and Duel.SelectYesNo(tp,aux.Stringid(38943357,0)) then  --"要在场上放置魔力指示物吗？"
			while ct>0 do
				-- 效果作用：提示玩家选择要放置魔力指示物的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
				-- 效果作用：选择可以放置魔力指示物的卡
				local tc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,1,1,nil,0x1,1):GetFirst()
				if not tc then break end
				tc:AddCounter(0x1,1)
				ct=ct-1
			end
		end
	end
end
