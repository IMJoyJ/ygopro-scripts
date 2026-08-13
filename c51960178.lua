--フェアリー・チア・ガール
-- 效果：
-- 天使族4星怪兽×2
-- 把这张卡1个超量素材取除才能发动。从卡组抽1张卡。「妖精啦啦队少女」的效果1回合只能使用1次。
function c51960178.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只天使族4星怪兽作为超量素材叠放召唤。
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
-- 发动代价：取除这张卡的1个超量素材；先检查能否取除，确定发动时实际取除1个素材作为代价。
function c51960178.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设定效果对象：以当前玩家tp为对象，抽卡数量为1，并登记抽卡操作信息（抽卡效果不取对象）。
function c51960178.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：当前玩家tp是否能够抽1张卡（即是否受到不能抽卡效果的限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将效果的对象玩家设为当前玩家tp，指定由tp进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将效果参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记抽卡效果的操作信息，用于规则判定：目标玩家为tp，预计抽卡数为1，不指定具体的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：从连锁信息中取得对象玩家和抽卡数量，实际执行抽卡。
function c51960178.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家p和抽卡数量d，供后续抽卡处理使用。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果处理为原因，让玩家p抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
