--十種神鏡陣
-- 效果：
-- ①：等级合计直到变成10星为止，从自己的手卡·场上（表侧表示）把怪兽任意数量送去墓地才能发动。自己抽2张。
local s,id,o=GetID()
-- 注册卡片效果，设置为发动时点、抽卡类别、玩家目标、自由连锁、并绑定消耗、目标和发动函数
function s.initial_effect(c)
	-- ①：等级合计直到变成10星为止，从自己的手卡·场上（表侧表示）把怪兽任意数量送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义用于筛选满足条件的怪兽的过滤函数，要求怪兽等级大于等于0、表侧表示且能作为代价送去墓地
function s.costfilter(c)
	return c:IsLevelAbove(0) and c:IsFaceupEx() and c:IsAbleToGraveAsCost()
end
-- 处理效果消耗，获取玩家手牌和场上的怪兽组，检查是否存在满足等级合计为10的组合，若存在则提示选择并发送至墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手牌与场上所有表侧表示的怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckWithSumEqual(Card.GetLevel,10,1,#g) end
	-- 向玩家发送提示信息，提示其选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,10,1,#g)
	-- 将选中的卡片组以代价原因送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 设置效果目标，检查玩家是否可以抽2张卡，并设定目标玩家和参数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁操作的目标玩家为当前处理的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作的目标参数为2（表示抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息，指定类别为抽卡、目标玩家为当前玩家、抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 发动效果时执行的操作函数，获取连锁中的目标玩家和参数并执行抽卡效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和目标参数（即抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让指定玩家抽取相应数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
