--停戦協定
-- 效果：
-- ①：场上有效果怪兽或者里侧守备表示怪兽存在的场合才能发动。场上的里侧守备表示怪兽全部变成表侧守备表示。这个时候，反转怪兽的效果不发动。给与对方为场上的效果怪兽数量×500伤害。
function c36468556.initial_effect(c)
	-- ①：场上有效果怪兽或者里侧守备表示怪兽存在的场合才能发动。场上的里侧守备表示怪兽全部变成表侧守备表示。这个时候，反转怪兽的效果不发动。给与对方为场上的效果怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36468556.target)
	e1:SetOperation(c36468556.activate)
	c:RegisterEffect(e1)
end
-- 效果怪兽或里侧守备表示怪兽过滤函数
function c36468556.tgfilter(c)
	return (c:IsFaceup() and c:IsType(TYPE_EFFECT)) or c:IsFacedown()
end
-- 效果怪兽过滤函数
function c36468556.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 发动时点处理函数，检查是否满足发动条件并设置伤害值
function c36468556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在效果怪兽或里侧守备表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36468556.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 计算场上的效果怪兽数量并乘以500作为伤害值
	local dam=Duel.GetMatchingGroupCount(c36468556.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为伤害值
	Duel.SetTargetParam(dam)
	-- 若伤害值大于0，则设置连锁操作信息为伤害效果
	if dam>0 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam) end
end
-- 发动效果处理函数，将里侧守备表示怪兽变为表侧守备表示并造成伤害
function c36468556.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的里侧守备表示怪兽组
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将里侧守备表示怪兽全部变为表侧守备表示，且反转效果不发动
	Duel.ChangePosition(g,0x1,0x1,0x4,0x4,true)
	-- 获取连锁对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算场上的效果怪兽数量并乘以500作为伤害值
	local dam=Duel.GetMatchingGroupCount(c36468556.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 对对方造成计算出的伤害值
	Duel.Damage(p,dam,REASON_EFFECT)
end
