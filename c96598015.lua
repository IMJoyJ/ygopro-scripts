--金満な壺
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能作灵摆召唤以外的特殊召唤。
-- ①：从自己的额外卡组的表侧表示的灵摆怪兽以及自己墓地的灵摆怪兽之中选合计3只，回到卡组洗切。那之后，自己从卡组抽2张。
function c96598015.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能作灵摆召唤以外的特殊召唤。①：从自己的额外卡组的表侧表示的灵摆怪兽以及自己墓地的灵摆怪兽之中选合计3只，回到卡组洗切。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,96598015+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c96598015.cost)
	e1:SetTarget(c96598015.target)
	e1:SetOperation(c96598015.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合玩家进行特殊召唤的次数
	Duel.AddCustomActivityCounter(96598015,ACTIVITY_SPSUMMON,c96598015.counterfilter)
end
-- 计数器过滤函数：如果特殊召唤的怪兽是灵摆召唤，则不计入计数器
function c96598015.counterfilter(c)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 发动代价处理：检查本回合是否进行过灵摆召唤以外的特殊召唤，并注册本回合不能进行灵摆召唤以外的特殊召唤的限制效果
function c96598015.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否未进行过灵摆召唤以外的特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(96598015,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能作灵摆召唤以外的特殊召唤。①：从自己的额外卡组的表侧表示的灵摆怪兽以及自己墓地的灵摆怪兽之中选合计3只，回到卡组洗切。那之后，自己从卡组抽2张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96598015.splimit)
	-- 在全局注册该不能特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的类型：非灵摆召唤的特殊召唤被禁止
function c96598015.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)~=SUMMON_TYPE_PENDULUM
end
-- 过滤函数：选择自己墓地或额外卡组表侧表示的、可以回到卡组的灵摆怪兽
function c96598015.filter(c)
	return c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
-- 效果发动时的目标选择与合法性检查
function c96598015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己的额外卡组和墓地中是否存在合计3只满足条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(c96598015.filter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,3,nil) end
	-- 设置操作信息：预计将3张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,0,0)
	-- 设置操作信息：预计让玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：执行回到卡组洗切并抽卡的效果
function c96598015.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己额外卡组和墓地中满足条件且不受王家长眠之谷影响的灵摆怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c96598015.filter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	if g:GetCount()<3 then return end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:Select(tp,3,3,nil)
	-- 将选中的3张卡送回卡组
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作的卡片组
	local og=Duel.GetOperatedGroup()
	-- 如果有卡片实际回到了主卡组，则洗切主卡组
	if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		-- 中断当前效果处理，使后续的抽卡处理与回卡组处理不视为同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
