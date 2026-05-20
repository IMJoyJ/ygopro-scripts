--幸運の笛吹き
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当通常召唤使用的再度召唤，这张卡当作效果怪兽使用并得到以下效果。
-- ●这张卡战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。
function c68762510.initial_effect(c)
	-- 为卡片添加二重怪兽属性（在墓地或场上表侧表示存在时当作通常怪兽，再度召唤后当作效果怪兽）
	aux.EnableDualAttribute(c)
	-- ●这张卡战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68762510,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c68762510.con)
	e1:SetTarget(c68762510.tg)
	e1:SetOperation(c68762510.op)
	c:RegisterEffect(e1)
end
-- 判断效果发动条件：自身处于再度召唤状态，且战斗破坏的怪兽被送去墓地
function c68762510.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否处于再度召唤状态（二重状态）
	if not aux.IsDualState(e) then return false end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE) and bc:IsType(TYPE_MONSTER)
end
-- 设置抽卡效果的目标玩家为自己，目标参数为1张卡，并注册操作信息
function c68762510.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果的具体处理
function c68762510.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
