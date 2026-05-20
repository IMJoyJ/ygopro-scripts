--うごめく影
-- 效果：
-- 支付300基本分，自己的主要怪兽区域的里侧守备表示怪兽洗切，再以里侧守备表示重新排列。这个效果1个回合只能使用1次。
function c59237154.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 支付300基本分，自己的主要怪兽区域的里侧守备表示怪兽洗切，再以里侧守备表示重新排列。这个效果1个回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59237154,0))  --"里侧怪兽洗切"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c59237154.cost)
	e2:SetTarget(c59237154.target)
	e2:SetOperation(c59237154.operation)
	c:RegisterEffect(e2)
end
-- 定义效果发动的代价（Cost）函数，用于检查并支付基本分
function c59237154.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查玩家是否能够支付300点基本分
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 在效果发动时，让玩家支付300点基本分
	Duel.PayLPCost(tp,300)
end
-- 过滤条件：属于主要怪兽区域（序号小于5）且处于里侧表示的怪兽
function c59237154.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 定义效果的目标（Target）函数，用于检查发动条件
function c59237154.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否存在至少2张里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59237154.filter,tp,LOCATION_MZONE,0,2,nil) end
end
-- 定义效果的执行（Operation）函数，用于洗切并重新排列怪兽
function c59237154.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己主要怪兽区域中所有符合条件的里侧表示怪兽
	local g=Duel.GetMatchingGroup(c59237154.filter,tp,LOCATION_MZONE,0,nil)
	-- 将获取到的里侧表示怪兽洗切并以里侧守备表示重新排列
	Duel.ShuffleSetCard(g)
end
