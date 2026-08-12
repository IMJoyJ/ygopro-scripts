--フェアリー・チア・ガール
-- 效果：
-- 天使族4星怪兽×2
-- 把这张卡1个超量素材取除才能发动。从卡组抽1张卡。「妖精啦啦队少女」的效果1回合只能使用1次。
function c51960178.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足种族为天使族的4星怪兽作为素材进行召唤，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),4,2)
	c:EnableReviveLimit()
	-- 把这张卡1个超量素材取除才能发动。从卡组抽1张卡。「妖精啦啦队少女」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(51960178,0))  --"抽卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,51960178)
	e1:SetCost(c51960178.cost)
	e1:SetTarget(c51960178.target)
	e1:SetOperation(c51960178.operation)
	c:RegisterEffect(e1)
end
-- 费用处理函数，检查并移除自身1个超量素材作为发动代价
function c51960178.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标设定函数，判断玩家是否可以抽卡并设置连锁操作信息
function c51960178.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁的目标玩家为效果使用者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为抽卡效果，影响对象为指定玩家，抽卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果发动时的处理函数，获取目标玩家和抽卡数量并执行抽卡
function c51960178.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡，原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
