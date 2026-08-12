--デス・ウサギ
-- 效果：
-- 反转：衍生物以外的自己场上表侧表示存在的通常怪兽每有1只，给与对方基本分1000分伤害。
function c49144107.initial_effect(c)
	-- 反转：衍生物以外的自己场上表侧表示存在的通常怪兽每有1只，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49144107,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c49144107.target)
	e1:SetOperation(c49144107.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，返回满足条件的场上表侧表示的通常怪兽（非衍生物）的数量
function c49144107.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
end
-- 效果处理时点，设置连锁对象玩家为对手，计算满足条件的怪兽数量并乘以1000作为伤害值，设置连锁操作信息为伤害效果
function c49144107.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为对手
	Duel.SetTargetPlayer(1-tp)
	-- 获取自己场上满足条件的通常怪兽数量，并乘以1000得到总伤害值
	local dam=Duel.GetMatchingGroupCount(c49144107.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 将当前连锁的目标参数设置为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置当前处理的连锁的操作信息，包含伤害效果、目标玩家和伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果发动时点，获取连锁对象玩家和满足条件的怪兽数量，计算总伤害并造成伤害
function c49144107.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取自己场上满足条件的通常怪兽数量，并乘以1000得到总伤害值
	local dam=Duel.GetMatchingGroupCount(c49144107.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 以效果原因对指定玩家造成相应伤害值
	Duel.Damage(p,dam,REASON_EFFECT)
end
