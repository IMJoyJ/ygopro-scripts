--紅蓮魔竜の壺
-- 效果：
-- 自己场上有「红莲魔龙」表侧表示存在的场合才能发动。从自己卡组抽2张卡。这张卡发动的场合，直到下次的对方回合结束时自己不能把怪兽召唤·特殊召唤。
function c87614611.initial_effect(c)
	-- 注册卡片记有「红莲魔龙」卡名的信息
	aux.AddCodeList(c,70902743)
	-- 自己场上有「红莲魔龙」表侧表示存在的场合才能发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c87614611.condition)
	e1:SetCost(c87614611.cost)
	e1:SetTarget(c87614611.target)
	e1:SetOperation(c87614611.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「红莲魔龙」
function c87614611.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 发动条件：自己场上存在表侧表示的「红莲魔龙」
function c87614611.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「红莲魔龙」
	return Duel.IsExistingMatchingCard(c87614611.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 发动代价（誓约）：检查本回合发动前自己是否进行过召唤或特殊召唤
function c87614611.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合发动前自己是否进行过怪兽的召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 并且检查本回合发动前自己是否进行过怪兽的特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的场合，直到下次的对方回合结束时自己不能把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	e1:SetTargetRange(1,0)
	-- 给玩家注册不能召唤怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的场合，直到下次的对方回合结束时自己不能把怪兽召唤·特殊召唤。从自己卡组抽2张卡。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	e2:SetTargetRange(1,0)
	-- 给玩家注册不能特殊召唤怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果发动时的目标处理：检查是否能抽卡并设置抽卡参数
function c87614611.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为2张卡
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的空间处理（效果处理）：执行抽卡
function c87614611.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
