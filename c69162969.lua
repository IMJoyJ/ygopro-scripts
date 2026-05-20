--ライトニング・ボルテックス
-- 效果：
-- ①：丢弃1张手卡才能发动。对方场上的表侧表示怪兽全部破坏。
function c69162969.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。对方场上的表侧表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c69162969.cost)
	e1:SetTarget(c69162969.target)
	e1:SetOperation(c69162969.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理函数：检查并执行丢弃1张手卡
function c69162969.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选表侧表示的卡片
function c69162969.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的目标选择与检测函数
function c69162969.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69162969.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示怪兽的卡片组
	local sg=Duel.GetMatchingGroup(c69162969.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理为破坏对方场上的这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理（Operation）函数：执行破坏对方场上所有表侧表示怪兽的操作
function c69162969.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对方场上所有的表侧表示怪兽
	local sg=Duel.GetMatchingGroup(c69162969.filter,tp,0,LOCATION_MZONE,nil)
	-- 将获取到的怪兽卡片组全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
