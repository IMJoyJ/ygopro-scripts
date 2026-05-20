--燃える藻
-- 效果：
-- 当这张卡被送去墓地时，对方回复1000基本分。
function c41859700.initial_effect(c)
	-- 当这张卡被送去墓地时，对方回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41859700,0))  --"回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c41859700.target)
	e1:SetOperation(c41859700.operation)
	c:RegisterEffect(e1)
end
-- 效果的目标设定阶段：确认可以发动后，设定对方玩家为效果对象并声明回复1000LP的操作信息
function c41859700.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的效果对象玩家为对方玩家（1-tp）
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的效果参数为1000（回复LP的数值）
	Duel.SetTargetParam(1000)
	-- 设置操作信息：声明此效果将让对方玩家回复1000LP（CATEGORY_RECOVER），用于系统检测和连锁确认
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 效果的处理执行阶段：获取目标玩家和回复数值，执行回复LP的操作
function c41859700.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设定的目标玩家（p）和回复数值（d）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让目标玩家（p）回复（d）1000LP
	Duel.Recover(p,d,REASON_EFFECT)
end
