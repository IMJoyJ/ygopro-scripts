--超弩級砲塔列車グスタフ・マックス
-- 效果：
-- 10星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给与对方2000伤害。
function c56910167.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：10星怪兽×2
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。给与对方2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56910167,0))  --"2000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c56910167.cost)
	e1:SetTarget(c56910167.target)
	e1:SetOperation(c56910167.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：把这张卡1个超量素材取除
function c56910167.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动的目标：设置对方玩家为伤害对象，伤害数值为2000，并向系统宣告该效果
function c56910167.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为2000
	Duel.SetTargetParam(2000)
	-- 设置当前连锁的操作信息为给与对方玩家2000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
-- 效果处理：获取目标玩家和伤害数值，给与对方2000点伤害
function c56910167.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
