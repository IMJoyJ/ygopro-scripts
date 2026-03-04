--Ai－コンタクト
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的场地区域有「火灵天星“艾”心乐园岛」存在的场合，把手卡1张「火灵天星“艾”心乐园岛」给对方观看才能发动。给人观看的卡回到卡组最下面，自己从卡组抽3张。
function c10493654.initial_effect(c)
	-- 为卡片注册关联卡片代码59054773，用于后续判断是否包含该卡片
	aux.AddCodeList(c,59054773)
	-- ①：自己的场地区域有「火灵天星“艾”心乐园岛」存在的场合，把手卡1张「火灵天星“艾”心乐园岛」给对方观看才能发动。给人观看的卡回到卡组最下面，自己从卡组抽3张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10493654,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,10493654+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10493654.condition)
	e1:SetCost(c10493654.cost)
	e1:SetTarget(c10493654.target)
	e1:SetOperation(c10493654.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手卡中满足条件的「火灵天星“艾”心乐园岛」卡片
function c10493654.cfilter(c)
	return c:IsCode(59054773) and not c:IsPublic() and c:IsAbleToDeck()
end
-- 判断发动条件是否满足，检查场地区域是否存在「火灵天星“艾”心乐园岛」
function c10493654.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场地区域是否存在编号为59054773的场地卡
	return Duel.IsEnvironment(59054773,tp,LOCATION_FZONE)
end
-- 设置发动时的费用处理逻辑
function c10493654.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 设置效果的发动目标选择逻辑
function c10493654.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手卡中是否存在至少1张「火灵天星“艾”心乐园岛」且玩家可以抽3张卡
		return Duel.IsExistingMatchingCard(c10493654.cfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,3)
	end
	e:SetLabel(0)
	-- 向玩家提示选择要确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	-- 从玩家手卡中选择1张「火灵天星“艾”心乐园岛」作为目标
	local g=Duel.SelectMatchingCard(tp,c10493654.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示所选的卡片
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家手卡洗牌
	Duel.ShuffleHand(tp)
	-- 设置当前效果处理的目标卡片
	Duel.SetTargetCard(g)
	-- 设置操作信息，标记将目标卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息，标记将从卡组抽3张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
-- 设置效果发动后的处理逻辑
function c10493654.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果处理的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否仍然存在于连锁中，是否成功送回卡组且位于卡组中
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
		-- 让玩家从卡组抽3张卡
		Duel.Draw(tp,3,REASON_EFFECT)
	end
end
