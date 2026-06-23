--軽量化
-- 效果：
-- 将手卡1只7星以上的怪兽加入卡组并且洗切，之后抽1张卡。这个效果1回合只能发动1次。
function c37231841.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 将手卡1只7星以上的怪兽加入卡组并且洗切，之后抽1张卡。这个效果1回合只能发动1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37231841,0))  --"交换手牌"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c37231841.target)
	e2:SetOperation(c37231841.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中等级7以上的可送入卡组的怪兽
function c37231841.filter(c)
	return c:IsLevelAbove(7) and c:IsAbleToDeck()
end
-- 效果的发动条件判断，检查玩家是否可以抽卡且手卡是否存在满足条件的怪兽
function c37231841.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡中是否存在至少1张等级7以上的怪兽
		and Duel.IsExistingMatchingCard(c37231841.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果处理时将要送入卡组的卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置效果处理时将要抽卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果的处理函数，执行将怪兽送入卡组并抽卡的操作
function c37231841.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以抽卡，若不可以则中断效果处理
	if not Duel.IsPlayerCanDraw(tp) then return end
	-- 提示玩家选择要送入卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1张手卡怪兽
	local g=Duel.SelectMatchingCard(tp,c37231841.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 向对方确认所选怪兽的卡面信息
		Duel.ConfirmCards(1-tp,g)
		-- 将选中的怪兽送入卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 手动洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
