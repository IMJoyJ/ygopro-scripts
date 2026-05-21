--ニードル・ボール
-- 效果：
-- 反转：可以支付2000分，对方受到1000分的伤害。
function c94230224.initial_effect(c)
	-- 反转：可以支付2000分，对方受到1000分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94230224,0))  --"反转"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetCost(c94230224.cost)
	e1:SetTarget(c94230224.target)
	e1:SetOperation(c94230224.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数：检查并支付2000点基本分
function c94230224.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查发动玩家是否能支付2000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让发动玩家支付2000点基本分
	Duel.PayLPCost(tp,2000)
end
-- 定义效果的目标（Target）函数：设定伤害对象为对方玩家，伤害数值为1000
function c94230224.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的对象玩家设定为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将效果的对象参数（伤害数值）设定为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：给与对方玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 定义效果的处理（Operation）函数：执行伤害处理
function c94230224.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
