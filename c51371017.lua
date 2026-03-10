--剣の女王
-- 效果：
-- 反转：对方场上每存在1张魔法·陷阱，对方受到500分的伤害。
function c51371017.initial_effect(c)
	-- 反转：对方场上每存在1张魔法·陷阱，对方受到500分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51371017,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c51371017.target)
	e1:SetOperation(c51371017.operation)
	c:RegisterEffect(e1)
end
-- 效果作用
function c51371017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方设为效果的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 计算己方场上的魔法·陷阱卡数量并乘以500得到伤害值
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)*500
	-- 设置本次连锁的效果伤害值
	Duel.SetTargetParam(dam)
	-- 设置本次连锁的伤害操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果作用
function c51371017.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算目标玩家场上的魔法·陷阱卡数量并乘以500得到伤害值
	local dam=Duel.GetFieldGroupCount(p,LOCATION_SZONE,0)*500
	-- 对目标玩家造成对应伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
