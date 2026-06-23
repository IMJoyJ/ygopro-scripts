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
-- 定义效果发动的目标与参数设置函数
function c51371017.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 获取对方魔陷区的卡片数量并乘以500，计算出预估伤害值
	local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)*500
	-- 设置当前连锁的对象参数为预估伤害值
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息为对对方玩家造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 定义效果处理函数，获取目标玩家并根据其魔陷区卡片数量给予伤害
function c51371017.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家魔陷区的卡片数量并乘以500，计算出实际伤害值
	local dam=Duel.GetFieldGroupCount(p,LOCATION_SZONE,0)*500
	-- 对目标玩家造成计算出的效果伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
