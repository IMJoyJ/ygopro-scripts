--死霊騎士デスカリバー・ナイト
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：怪兽的效果发动时，把这张卡解放发动。那个发动无效并破坏。
function c78700060.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：怪兽的效果发动时，把这张卡解放发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78700060,1))  --"怪物效果发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c78700060.condition)
	e2:SetCost(c78700060.cost)
	e2:SetTarget(c78700060.target)
	e2:SetOperation(c78700060.operation)
	c:RegisterEffect(e2)
end
-- 判断发动的效果是否为怪兽的效果
function c78700060.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 发动代价处理：检查自身是否可以解放，并在发动时将自身解放
function c78700060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果的目标处理：此效果为必发效果，直接返回true，并设置使发动无效和破坏的操作信息
function c78700060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果包含“使发动无效”的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示该效果包含“破坏”的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果的运行处理：使该怪兽效果的发动无效并破坏
function c78700060.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否紧跟在要无效的效果之后，若不是则不处理
	if Duel.GetCurrentChain()~=ev+1 then return end
	-- 尝试使该效果的发动无效，若成功且该卡仍与该效果关联，则进行后续处理
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动效果的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
