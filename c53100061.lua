--X－セイバー アクセル
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，名字带有「剑士」的怪兽被战斗破坏送去墓地时，从自己卡组抽1张卡。
function c53100061.initial_effect(c)
	-- 诱发必发效果，当名字带有「剑士」的怪兽被战斗破坏送去墓地时发动
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
-- 过滤满足条件的卡片：名字带有「剑士」且在墓地且因战斗破坏
function c53100061.filter(c)
	return c:IsSetCard(0xd) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 判断是否有满足条件的卡片被战斗破坏
function c53100061.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c53100061.filter,1,nil)
end
-- 设置效果处理目标为自身玩家并设定抽卡数量为1张
function c53100061.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设为1（表示抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置操作信息为抽卡效果，影响对象为自己，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,tp,1)
end
-- 执行抽卡操作，从自己卡组抽取1张卡
function c53100061.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家从卡组抽指定数量的卡，原因来自效果
	Duel.Draw(p,d,REASON_EFFECT)
end
