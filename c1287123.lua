--マテリアルファルコ
-- 效果：
-- 持有「把场上的魔法·陷阱卡破坏的效果」的效果怪兽的效果发动时，可以把1张手卡送去墓地让那个发动无效并破坏。
function c1287123.initial_effect(c)
	-- 持有「把场上的魔法·陷阱卡破坏的效果」的效果怪兽的效果发动时，可以把1张手卡送去墓地让那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1287123,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c1287123.condition)
	e1:SetCost(c1287123.cost)
	e1:SetTarget(c1287123.target)
	e1:SetOperation(c1287123.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡是否在场上且为魔法或陷阱类型
function c1287123.filter(c)
	return c:IsOnField() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的发动条件判断函数
function c1287123.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否处于战斗破坏状态或连锁是否可无效，若满足则返回false
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) or re:IsHasCategory(CATEGORY_NEGATE) then return false end
	-- 获取连锁发动时的破坏相关信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c1287123.filter,nil)-tg:GetCount()>0
end
-- 支付代价时的处理函数
function c1287123.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家丢弃1张手卡作为代价
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 效果发动时的目标设定函数
function c1287123.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁发动破坏的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果发动时的处理函数
function c1287123.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效并检查目标卡是否有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
