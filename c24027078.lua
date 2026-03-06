--アヴァロンの魔女モルガン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己场上有「圣骑士」怪兽以及「圣剑」装备魔法卡存在，对方把魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。选自己场上1张「圣剑」装备魔法卡破坏，那个发动无效。
function c24027078.initial_effect(c)
	-- 创建效果1，设置效果描述、分类、类型、代码、属性、适用范围、使用次数限制、发动条件、发动代价、发动目标和发动效果
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
-- 过滤函数1：检查场上是否存在「圣骑士」怪兽
function c24027078.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- 过滤函数2：检查场上是否存在「圣剑」装备魔法卡
function c24027078.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x207a) and c:IsType(TYPE_EQUIP)
end
-- 发动条件函数：判断对方发动魔法·陷阱·怪兽效果时，己方场上有「圣骑士」怪兽和「圣剑」装备魔法卡
function c24027078.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方发动效果且该效果可以被无效
	return ep~=tp and Duel.IsChainNegatable(ev)
		-- 判断己方场上存在至少1只「圣骑士」怪兽
		and Duel.IsExistingMatchingCard(c24027078.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 判断己方场上存在至少1张「圣剑」装备魔法卡
		and Duel.IsExistingMatchingCard(c24027078.filter2,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 发动代价函数：将自身送去墓地作为代价
function c24027078.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身从手牌送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动目标函数：设置发动时需要处理的效果分类（使发动无效和破坏卡）
function c24027078.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取己方场上所有「圣剑」装备魔法卡
	local g=Duel.GetMatchingGroup(c24027078.filter2,tp,LOCATION_ONFIELD,0,nil)
	-- 设置发动时要使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置发动时要破坏己方场上1张「圣剑」装备魔法卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 发动效果函数：选择并破坏1张「圣剑」装备魔法卡，然后使对方效果无效
function c24027078.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方场上1张「圣剑」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c24027078.filter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 判断是否成功破坏了卡并执行效果无效
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 使对方效果无效
		Duel.NegateActivation(ev)
	end
end
