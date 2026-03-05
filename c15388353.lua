--Nouvellez Auberge 『À Table』
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地选1张「食谱」卡加入手卡。
-- ②：1回合1次，从手卡让1只仪式怪兽回到卡组最下面才能发动。自己从卡组抽1张。
-- ③：自己结束阶段，以包含「食谱」卡的自己墓地2张卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己从卡组抽1张。
local s,id,o=GetID()
-- 注册卡片的3个效果：①发动时检索「食谱」卡；②手卡仪式怪兽回到卡组底端并抽卡；③结束阶段将墓地2张「食谱」卡放回卡组底端并抽卡
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从自己的卡组·墓地选1张「食谱」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡让1只仪式怪兽回到卡组最下面才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.drcost1)
	e2:SetTarget(s.drtg1)
	e2:SetOperation(s.drop1)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段，以包含「食谱」卡的自己墓地2张卡为对象才能发动。那些卡用喜欢的顺序回到卡组下面。那之后，自己从卡组抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.drcon2)
	e3:SetTarget(s.drtg2)
	e3:SetOperation(s.drop2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「食谱」卡过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x197) and c:IsAbleToHand()
end
-- 效果处理：检索满足条件的「食谱」卡并加入手牌
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「食谱」卡组（包括卡组和墓地）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 判断是否满足检索条件并询问玩家是否发动
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否选1张「食谱」卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对手确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 支付效果费用的过滤函数
function s.costfilter(c)
	return c:GetType()&0x81==0x81 and c:IsAbleToDeckAsCost()
end
-- 效果处理：支付1张手卡仪式怪兽作为费用并抽卡
function s.drcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足支付费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择支付费用的卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对手确认支付费用的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将支付费用的卡返回卡组底端
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 设置效果目标：抽卡
function s.drtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足抽卡条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果目标参数
	Duel.SetTargetParam(1)
	-- 设置效果操作信息：抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：执行抽卡
function s.drop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 结束阶段效果触发条件
function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 选择墓地「食谱」卡的过滤函数
function s.tdfilter(c,tp)
	return c:IsSetCard(0x197) and c:IsAbleToDeck()
		-- 判断是否满足选择墓地卡的条件
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,c)
end
-- 设置效果目标：选择墓地2张「食谱」卡
function s.drtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足抽卡条件
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 判断是否满足选择墓地卡的条件
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择第一张要返回卡组的卡
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择第二张要返回卡组的卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,1,g)
	g:Merge(g2)
	-- 设置效果操作信息：将卡放回卡组底端
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	-- 设置效果操作信息：抽卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：将选择的卡放回卡组底端并抽卡
function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与连锁相关的卡组
	local g=Duel.GetTargetsRelateToChain()
	-- 判断是否满足处理条件
	if #g==0 or aux.PlaceCardsOnDeckBottom(tp,g)==0 then return end
	-- 中断当前效果
	Duel.BreakEffect()
	-- 执行抽卡效果
	Duel.Draw(tp,1,REASON_EFFECT)
end
