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
-- 过滤函数：判断手牌中的怪兽是否为7星以上且可以返回卡组。
function c37231841.filter(c)
	return c:IsLevelAbove(7) and c:IsAbleToDeck()
end
-- 发动条件与目标选择前的检查：确认玩家可以抽卡，并且手牌中存在至少1只满足条件的7星以上怪兽。
function c37231841.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够抽卡，作为效果可发动的条件之一。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手牌中是否存在至少1张符合条件的7星以上怪兽，作为效果可发动的条件之一。
		and Duel.IsExistingMatchingCard(c37231841.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：本效果会将1张手牌返回卡组，用于连锁判定和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本效果会抽1张卡，用于连锁判定和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：选择手卡1只7星以上怪兽返回卡组并洗切，之后抽1张卡。
function c37231841.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认玩家可以抽卡，若不能则直接结束处理。
	if not Duel.IsPlayerCanDraw(tp) then return end
	-- 弹出选择提示，要求玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择1只满足条件的7星以上怪兽作为返回卡组的对象。
	local g=Duel.SelectMatchingCard(tp,c37231841.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 向对方玩家展示所选择的手牌怪兽，确认选择结果。
		Duel.ConfirmCards(1-tp,g)
		-- 将选择的怪兽返回持有者卡组，并标记为需要洗切。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		-- 洗切我方卡组。
		Duel.ShuffleDeck(tp)
		-- 中断当前效果链，使后续抽卡处理与回卡组处理视为不同时处理，避免错误时点。
		Duel.BreakEffect()
		-- 抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
