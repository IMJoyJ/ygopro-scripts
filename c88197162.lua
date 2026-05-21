--魂の転身
-- 效果：
-- 「魂之转身」在1回合只能发动1张，这张卡发动的回合，自己不能把怪兽特殊召唤。
-- ①：自己场上没有特殊召唤的怪兽存在的场合，把自己场上1只通常召唤的表侧表示的4星怪兽解放才能发动。自己从卡组抽2张。
function c88197162.initial_effect(c)
	-- 「魂之转身」在1回合只能发动1张，这张卡发动的回合，自己不能把怪兽特殊召唤。①：自己场上没有特殊召唤的怪兽存在的场合，把自己场上1只通常召唤的表侧表示的4星怪兽解放才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88197162+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c88197162.condition)
	e1:SetCost(c88197162.cost)
	e1:SetTarget(c88197162.target)
	e1:SetOperation(c88197162.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查怪兽是否为特殊召唤
function c88197162.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动条件：自己场上没有特殊召唤的怪兽存在
function c88197162.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在特殊召唤的怪兽，若不存在则返回true
	return not Duel.IsExistingMatchingCard(c88197162.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查怪兽是否为表侧表示、4星且为通常召唤
function c88197162.filter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 发动代价的检查：本回合自己没有进行过特殊召唤，且自己场上有满足条件的怪兽可供解放
function c88197162.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合自己是否未进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		-- 并且检查自己场上是否存在至少1只满足条件的表侧表示4星通常召唤怪兽可供解放
		and Duel.CheckReleaseGroup(tp,c88197162.filter,1,nil) end
	-- 选择自己场上1只满足条件的表侧表示4星通常召唤怪兽
	local g=Duel.SelectReleaseGroup(tp,c88197162.filter,1,1,nil)
	-- 将选中的怪兽解放作为发动的代价
	Duel.Release(g,REASON_COST)
	-- 这张卡发动的回合，自己不能把怪兽特殊召唤。自己从卡组抽2张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册不能特殊召唤怪兽的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动目标：检查玩家是否能抽2张卡，并设置抽卡操作信息
function c88197162.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置效果处理的操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：获取目标玩家和抽卡数量，执行抽卡效果
function c88197162.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
