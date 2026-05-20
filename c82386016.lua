--烏合の行進
-- 效果：
-- 自己场上有兽族·兽战士族·鸟兽族的其中任意的怪兽存在的场合，那些种族每有1种类从卡组抽1张卡。这张卡发动的回合，自己不能把其他的魔法·陷阱卡的效果发动。
function c82386016.initial_effect(c)
	-- 自己场上有兽族·兽战士族·鸟兽族的其中任意的怪兽存在的场合，那些种族每有1种类从卡组抽1张卡。这张卡发动的回合，自己不能把其他的魔法·陷阱卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c82386016.cost)
	e1:SetTarget(c82386016.target)
	e1:SetOperation(c82386016.activate)
	c:RegisterEffect(e1)
	-- 添加自定义活动计数器，用于监控玩家发动魔法·陷阱卡效果的次数
	Duel.AddCustomActivityCounter(82386016,ACTIVITY_CHAIN,c82386016.chainfilter)
end
-- 计数器过滤函数：过滤掉魔法和陷阱卡的效果发动（即非魔陷效果的发动不计入计数器）
function c82386016.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动代价（Cost）处理函数，检查并注册本回合不能发动其他魔陷效果的限制
function c82386016.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合在此之前是否没有发动过其他魔法·陷阱卡的效果
	if chk==0 then return Duel.GetCustomActivityCount(82386016,tp,ACTIVITY_CHAIN)==0 end
	-- 这张卡发动的回合，自己不能把其他的魔法·陷阱卡的效果发动。自己场上有兽族·兽战士族·鸟兽族的其中任意的怪兽存在的场合，那些种族每有1种类从卡组抽1张卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c82386016.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册全局效果，限制其在本回合内不能发动其他魔法·陷阱卡的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的过滤函数：禁止发动魔法和陷阱卡的效果
function c82386016.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：筛选自己场上表侧表示的兽族、兽战士族或鸟兽族怪兽
function c82386016.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- 效果发动目标（Target）确定函数，计算可抽卡数量并进行抽卡效果的声明
function c82386016.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足条件的兽族、兽战士族、鸟兽族怪兽
	local g=Duel.GetMatchingGroup(c82386016.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	-- 在发动时，检查场上是否存在上述种族的怪兽，且玩家是否可以抽取对应数量的卡
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数为计算出的种族数量（即抽卡张数）
	Duel.SetTargetParam(ct)
	-- 设置效果处理信息，声明此效果为让玩家抽卡，张数为计算出的种族数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果运行（Operation）处理函数，执行抽卡操作
function c82386016.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取自己场上表侧表示的兽族、兽战士族、鸟兽族怪兽
	local g=Duel.GetMatchingGroup(c82386016.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetRace)
	-- 获取当前连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让目标玩家因效果抽取对应种族数量的卡片
	Duel.Draw(p,ct,REASON_EFFECT)
end
