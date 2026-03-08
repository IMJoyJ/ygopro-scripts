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
-- 效果作用
function c41859700.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设置为效果的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将回复的LP数值设置为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁的操作信息为回复效果，对象玩家为对方，回复值为1000
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1000)
end
-- 效果作用
function c41859700.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应数值的LP，原因来自效果
	Duel.Recover(p,d,REASON_EFFECT)
end
