--潜航母艦エアロ・シャーク
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给与对方为自己的除外状态的怪兽数量×100伤害。
function c5014629.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为3的怪兽进行叠放，需要2只
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
-- 检查是否可以移除1个超量素材作为效果的代价，并执行移除操作
function c5014629.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选场上正面表示的怪兽
function c5014629.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 设置效果的目标玩家和伤害值，并注册伤害效果的操作信息
function c5014629.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己除外区是否有至少1张正面表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5014629.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 统计自己除外区正面表示的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c5014629.filter,tp,LOCATION_REMOVED,0,nil)
	-- 将连锁的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为除外怪兽数量乘以100
	Duel.SetTargetParam(ct*100)
	-- 注册伤害效果的操作信息，指定伤害类别和目标玩家及伤害值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
-- 执行伤害效果，根据除外怪兽数量计算并给予对方相应伤害
function c5014629.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次统计自己除外区正面表示的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c5014629.filter,tp,LOCATION_REMOVED,0,nil)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果原因对目标玩家造成指定数值的伤害
	Duel.Damage(p,ct*100,REASON_EFFECT)
end
