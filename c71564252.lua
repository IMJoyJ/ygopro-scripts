--ライオウ
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，双方不能用抽卡以外的方法从卡组把卡加入手卡。此外，可以把自己场上表侧表示存在的这张卡送去墓地，让1只对方怪兽的特殊召唤无效并破坏。
function c71564252.initial_effect(c)
	-- 只要这张卡在自己场上表侧表示存在，双方不能用抽卡以外的方法从卡组把卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	-- 设置限制加入手卡的卡片来源为卡组
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e1)
	-- 此外，可以把自己场上表侧表示存在的这张卡送去墓地，让1只对方怪兽的特殊召唤无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(71564252,0))  --"特殊召唤无效并破坏"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCondition(c71564252.condition)
	e2:SetCost(c71564252.cost)
	e2:SetTarget(c71564252.target)
	e2:SetOperation(c71564252.operation)
	c:RegisterEffect(e2)
end
-- 特殊召唤无效效果的发动条件函数
function c71564252.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方进行特殊召唤、特殊召唤的怪兽数量为1只，且该特殊召唤不组成连锁
	return tp~=ep and eg:GetCount()==1 and Duel.GetCurrentChain()==0
end
-- 效果发动的代价（Cost）处理函数
function c71564252.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果发动的目标（Target）处理函数
function c71564252.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果分类为无效特殊召唤，并指定操作对象为正在特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置效果分类为破坏，并指定操作对象为正在特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果运行（Operation）处理函数
function c71564252.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 破坏目标怪兽
	Duel.Destroy(eg,REASON_EFFECT)
end
