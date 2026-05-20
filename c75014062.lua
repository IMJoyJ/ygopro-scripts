--魔力掌握
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。那之后，可以从卡组把1张「魔力掌握」加入手卡。
function c75014062.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以场上1张可以放置魔力指示物的卡为对象才能发动。给那张卡放置1个魔力指示物。那之后，可以从卡组把1张「魔力掌握」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,75014062+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c75014062.target)
	e1:SetOperation(c75014062.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且可以放置魔力指示物的卡
function c75014062.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x1,1)
end
-- 效果发动时的对象选择与操作信息设置
function c75014062.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c75014062.filter(chkc) end
	-- 检查场上是否存在可以放置魔力指示物的卡作为合法对象
	if chk==0 then return Duel.IsExistingTarget(c75014062.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择场上1张可以放置魔力指示物的卡作为对象
	Duel.SelectTarget(tp,c75014062.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为给卡片放置1个魔力指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
-- 过滤卡组中卡名为「魔力掌握」且能加入手牌的卡
function c75014062.tfilter(c)
	return c:IsCode(75014062) and c:IsAbleToHand()
end
-- 效果处理，给对象卡放置魔力指示物，并可选从卡组检索「魔力掌握」
function c75014062.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:AddCounter(0x1,1) then
		-- 获取卡组中第一张满足条件的「魔力掌握」
		local th=Duel.GetFirstMatchingCard(c75014062.tfilter,tp,LOCATION_DECK,0,nil)
		-- 如果卡组有「魔力掌握」，询问玩家是否将其加入手牌
		if th and Duel.SelectYesNo(tp,aux.Stringid(75014062,0)) then  --"是否要把1张「魔力掌握」加入手牌？"
			-- 中断当前效果，使后续的检索处理与放置指示物不视为同时处理
			Duel.BreakEffect()
			-- 将检索到的「魔力掌握」加入手牌
			Duel.SendtoHand(th,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,th)
		end
	end
end
