--X－セイバー アクセル
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，名字带有「剑士」的怪兽被战斗破坏送去墓地时，从自己卡组抽1张卡。
function c53100061.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，名字带有「剑士」的怪兽被战斗破坏送去墓地时，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53100061,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c53100061.condition)
	e1:SetTarget(c53100061.target)
	e1:SetOperation(c53100061.operation)
	c:RegisterEffect(e1)
end
-- 筛选被战斗破坏送去墓地且名字带有「剑士」字段的怪兽（要求位于墓地且破坏原因为战斗破坏）。
function c53100061.filter(c)
	return c:IsSetCard(0xd) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 检查本次战斗破坏送去墓地的怪兽中是否存在至少1只满足上述筛选条件的「剑士」怪兽，以此作为效果发动条件。
function c53100061.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53100061.filter,1,nil)
end
-- 效果发动时登记对象玩家为自己、抽卡数量为1，并设置操作信息为抽卡效果；若仅在处理发动合法性检查（chk==0）时直接返回true。
function c53100061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果发动者自己（tp），表示由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置本次连锁的操作信息为抽卡效果，目标玩家为tp，抽卡数为1，便于其他卡牌进行连锁响应或效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
-- 效果处理时取出记录的对象玩家和抽卡数量，并让对应的玩家执行抽卡。
function c53100061.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的对象玩家（p）和对象参数（d），即抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，完成“从自己卡组抽1张卡”的效果处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
