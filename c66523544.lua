--超次元ロボ ギャラクシー・デストロイヤー
-- 效果：
-- 10星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除才能发动（对方不能对应这个效果的发动把魔法·陷阱卡发动）。对方场上的魔法·陷阱卡全部破坏。
function c66523544.initial_effect(c)
	-- 设置XYZ召唤手续：10星怪兽×3
	aux.AddXyzProcedure(c,nil,10,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动（对方不能对应这个效果的发动把魔法·陷阱卡发动）。对方场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66523544,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c66523544.cost)
	e1:SetTarget(c66523544.target)
	e1:SetOperation(c66523544.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：取除这张卡的1个超量素材
function c66523544.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：魔法或陷阱卡
function c66523544.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动的目标：确认对方场上有魔陷存在，并设置破坏的操作信息与连锁限制
function c66523544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1张魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66523544.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c66523544.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：预估将破坏对方场上的所有魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置连锁限制，使对方不能对应此效果的发动把魔法·陷阱卡发动
	Duel.SetChainLimit(c66523544.climit)
end
-- 效果处理：将对方场上的魔法·陷阱卡全部破坏
function c66523544.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c66523544.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 将目标卡片全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 连锁限制条件：限制对方不能发动魔法·陷阱卡（即魔陷的卡片发动）
function c66523544.climit(e,lp,tp)
	return lp==tp or not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
