--同族感染ウィルス
-- 效果：
-- ①：丢弃1张手卡，宣言1个种族才能发动。场上的宣言种族的怪兽全部破坏。
function c33184167.initial_effect(c)
	-- 效果原文内容：①：丢弃1张手卡，宣言1个种族才能发动。场上的宣言种族的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33184167,0))  --"宣言种族的怪兽全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c33184167.cost)
	e1:SetTarget(c33184167.target)
	e1:SetOperation(c33184167.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查是否可以丢弃1张手卡作为发动代价
function c33184167.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断玩家手牌中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 效果作用：执行丢弃1张手卡的操作，丢弃原因为代價+丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果作用：过滤函数，用于筛选场上表侧表示的怪兽
function c33184167.filter(c)
	return c:IsFaceup()
end
-- 效果作用：设置效果发动时的处理流程，包括选择种族和确定破坏目标
function c33184167.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c33184167.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：获取场上所有表侧表示的怪兽组成卡片组
	local g=Duel.GetMatchingGroup(c33184167.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	local race=0
	while tc do
		race=bit.bor(race,tc:GetRace())
		tc=g:GetNext()
	end
	-- 效果作用：向玩家发送提示信息，提示选择要宣言的种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 效果作用：让玩家从可选种族中宣言1个种族
	local arc=Duel.AnnounceRace(tp,1,race)
	e:SetLabel(arc)
	local dg=g:Filter(Card.IsRace,nil,arc)
	-- 效果作用：设置连锁操作信息，确定将要破坏的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果作用：过滤函数，用于筛选场上表侧表示且种族为rc的怪兽
function c33184167.filter2(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 效果作用：执行破坏操作，将符合条件的怪兽全部破坏
function c33184167.operation(e,tp,eg,ep,ev,re,r,rp)
	local arc=e:GetLabel()
	-- 效果作用：获取场上所有种族为指定种族的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c33184167.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil,arc)
	-- 效果作用：以效果原因破坏指定的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
