--アヴァロンの魔女モルガン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上有「圣骑士」怪兽以及「圣剑」装备魔法卡存在，对方把魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。选自己场上1张「圣剑」装备魔法卡破坏，那个发动无效。
function c24027078.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：自己场上有「圣骑士」怪兽以及「圣剑」装备魔法卡存在，对方把魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。选自己场上1张「圣剑」装备魔法卡破坏，那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24027078,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,24027078)
	e1:SetCondition(c24027078.condition)
	e1:SetCost(c24027078.cost)
	e1:SetTarget(c24027078.target)
	e1:SetOperation(c24027078.operation)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选取自己场上表侧表示且字段为「圣骑士」（0x107a）的怪兽。
function c24027078.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- 定义筛选条件：选取场上表侧表示且字段为「圣剑」（0x207a）的装备魔法卡。
function c24027078.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP)
end
-- 效果发动条件判定：对方发动效果且该连锁可被无效，并且自己场上有「圣骑士」怪兽和「圣剑」装备魔法卡存在。
function c24027078.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方是效果发动方（ep~=tp），且该连锁发动可以被无效。
	return ep~=tp and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在至少1张满足filter1的「圣骑士」怪兽（表侧表示且字段为圣骑士）。
		and Duel.IsExistingMatchingCard(c24027078.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己场上是否存在至少1张满足filter2的「圣剑」装备魔法卡（表侧表示且字段为圣剑的装备卡）。
		and Duel.IsExistingMatchingCard(c24027078.filter2,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 代价判定与支付：从手牌将这张卡送去墓地作为发动代价。chk==0时检查是否可以送去墓地；支付时将自身送去墓地。
function c24027078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡（效果持有者）从手牌送去墓地，作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动时的目标设定与操作信息登记：无特定对象但登记将无效对方那次效果发动，并破坏自己场上1张「圣剑」装备魔法卡。
function c24027078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上所有满足filter2的「圣剑」装备魔法卡，用于登记破坏的操作信息。
	local g=Duel.GetMatchingGroup(c24027078.filter2,tp,LOCATION_ONFIELD,0,nil)
	-- 登记操作信息：本次效果包含“使发动无效”，目标是当前连锁的对方发动的效果（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 登记操作信息：本次效果包含“破坏”，破坏对象为可能被选择的1张「圣剑」装备魔法卡（g），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：选择自己场上1张「圣剑」装备魔法卡破坏；若破坏成功，则无效对方那次效果的发动。
function c24027078.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者展示“请选择要破坏的卡”的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张满足filter2的「圣剑」装备魔法卡（表侧表示、圣剑字段、装备魔法）。
	local g=Duel.SelectMatchingCard(tp,c24027078.filter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 若成功选择了卡片且破坏成功，则进入无效处理（#g>0表示选中，Destroy返回值>0表示确实破坏了卡）。
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 无效对方那次效果的发动（即当前连锁上被响应发动的效果）。
		Duel.NegateActivation(ev)
	end
end
