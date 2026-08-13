--潜航母艦エアロ・シャーク
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给与对方为自己的除外状态的怪兽数量×100伤害。
function c5014629.initial_effect(c)
	-- 为潜航母舰航空鲨添加超量召唤手续：以任意2只3星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给与对方为自己的除外状态的怪兽数量×100伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5014629,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c5014629.damcost)
	e1:SetTarget(c5014629.damtg)
	e1:SetOperation(c5014629.damop)
	c:RegisterEffect(e1)
end
-- 代价函数：发动前检查能否从这张卡上去除1个超量素材作为代价；实际发动时去除这张卡的1个超量素材。
function c5014629.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：筛选出表侧表示的怪兽卡，用于统计自己除外状态中的表侧怪兽数量。
function c5014629.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 目标函数：确认自己除外区存在表侧表示怪兽后，统计其数量，将对方设置为承受伤害的玩家，并设置伤害参数及操作信息。
function c5014629.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认自己除外区是否存在至少1张表侧表示怪兽，以判断能否发动效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c5014629.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 统计自己除外区表侧表示怪兽的数量ct，用于计算伤害。
	local ct=Duel.GetMatchingGroupCount(c5014629.filter,tp,LOCATION_REMOVED,0,nil)
	-- 将本次连锁的对象玩家设置为对方（1-tp），即伤害的对象。
	Duel.SetTargetPlayer(1-tp)
	-- 将本次连锁的对象参数设置为ct×100，作为将要造成的伤害数值。
	Duel.SetTargetParam(ct*100)
	-- 设置操作信息：声明本连锁将造成伤害效果，对象为对方，预定伤害值为ct×100，供其他卡的效果作时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
-- 效果处理函数：在效果结算时重新统计自己除外区表侧表示怪兽的数量，从连锁信息中取得对象玩家，并给予对方对应伤害。
function c5014629.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新统计自己除外区表侧表示怪兽的数量，确保伤害按最新数量计算。
	local ct=Duel.GetMatchingGroupCount(c5014629.filter,tp,LOCATION_REMOVED,0,nil)
	-- 从当前连锁信息中取得发动时设置的对象玩家（即对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 给予对象玩家p造成ct×100的伤害，伤害来源为效果。
	Duel.Damage(p,ct*100,REASON_EFFECT)
end
