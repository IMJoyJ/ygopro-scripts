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
-- 筛选条件：表侧表示的效果怪兽或里侧表示怪兽，用于检查发动时场上是否存在满足条件的怪兽。
function c36468556.tgfilter(c)
	return (c:IsFaceup() and c:IsType(TYPE_EFFECT)) or c:IsFacedown()
end
-- 筛选条件：表侧表示的效果怪兽，用于统计场上效果怪兽数量。
function c36468556.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 发动时的目标处理：确认满足发动条件，计算并保存伤害值，设定对象玩家和伤害参数，并登记伤害操作信息。
function c36468556.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0）：判断场上是否存在至少1只表侧效果怪兽或里侧守备表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c36468556.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 计算伤害值：当前场上表侧表示的效果怪兽数量 × 500。
	local dam=Duel.GetMatchingGroupCount(c36468556.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 将本连锁效果的对象玩家设为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算好的伤害值保存为连锁对象参数，供效果处理阶段使用。
	Duel.SetTargetParam(dam)
	-- 当伤害值大于0时，登记伤害效果的操作信息：目标为对方、伤害值为dam；用于连锁检测与卡牌效果判定。
	if dam>0 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam) end
end
-- 效果处理时的操作：将场上所有里侧守备表示怪兽变为表侧守备表示且不触发反转效果，然后按处理时的场上表侧效果怪兽数量对对方造成伤害。
function c36468556.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有里侧表示怪兽（即里侧守备表示怪兽）作为要翻面的对象。
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将上述里侧怪兽全部变成表侧守备表示；最后参数true表示不触发反转怪兽的效果。
	Duel.ChangePosition(g,0x1,0x1,0x4,0x4,true)
	-- 从连锁信息中取出此前设定的对象玩家（对方），作为伤害的对象。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 翻面后重新计算当前场上表侧效果怪兽数量 ×500，作为实际伤害值。
	local dam=Duel.GetMatchingGroupCount(c36468556.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	-- 以效果原因给对方玩家造成dam点伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
