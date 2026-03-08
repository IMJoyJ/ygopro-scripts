--烈華砲艦ナデシコ
-- 效果：
-- 3星怪兽×3
-- 把这张卡1个超量素材取除才能发动。给与对方基本分对方手卡数量×200的数值的伤害。「烈华炮舰 抚子」的效果1回合只能使用1次。
function c40424929.initial_effect(c)
	-- 添加XYZ召唤手续，使用3星怪兽3只进行叠放
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- 把这张卡1个超量素材取除才能发动。给与对方基本分对方手卡数量×200的数值的伤害。「烈华炮舰 抚子」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40424929,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40424929)
	e1:SetCost(c40424929.damcost)
	e1:SetTarget(c40424929.damtg)
	e1:SetOperation(c40424929.damop)
	c:RegisterEffect(e1)
end
-- 检查是否能移除1个超量素材作为发动代价
function c40424929.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果发动时的处理目标，确定伤害计算方式
function c40424929.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	-- 获取对方手牌数量用于伤害计算
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息，指定造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
-- 执行伤害效果，对对方造成手牌数量×200的伤害
function c40424929.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取目标玩家手牌数量用于伤害计算
	local ct=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,ct*200,REASON_EFFECT)
end
