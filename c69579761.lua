--デス・コアラ
-- 效果：
-- ①：这张卡反转的场合发动。给与对方为对方手卡数量×400伤害。
function c69579761.initial_effect(c)
	-- ①：这张卡反转的场合发动。给与对方为对方手卡数量×400伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69579761,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c69579761.target)
	e1:SetOperation(c69579761.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认与设置函数，用于设定伤害的对象玩家和预计伤害数值
function c69579761.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 获取对方手牌数量并乘以400，作为预计伤害数值
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)*400
	-- 设置当前连锁的对象参数为预计伤害数值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息，声明该效果包含给与对方玩家指定数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数，获取目标玩家并根据其当前手牌数量给予伤害
function c69579761.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该玩家当前的手牌数量并乘以400，计算出实际伤害数值
	local dam=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*400
	-- 以效果伤害的形式给与目标玩家计算出的伤害数值
	Duel.Damage(p,dam,REASON_EFFECT)
end
