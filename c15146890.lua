--竜脈の魔術師
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- 【怪兽描述】
-- 优点只有精力充沛的新手少年魔术师。其实有着无意识间觉察到大地长眠的龙魂这种能力，虽然还是半吊子但其资质之高就连师父「龙穴之魔术师」也自认不如。
function c15146890.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15146890,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c15146890.condition)
	e2:SetCost(c15146890.cost)
	e2:SetTarget(c15146890.target)
	e2:SetOperation(c15146890.operation)
	c:RegisterEffect(e2)
end
-- 判断另一边的自己的灵摆区域是否存在「魔术师」卡
function c15146890.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的灵摆区域是否存在至少1张Set为0x98（魔术师）的卡
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 过滤函数，用于判断手牌中是否存在可以丢弃的灵摆怪兽
function c15146890.cfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 设置效果的发动费用，需要丢弃1只手牌中的灵摆怪兽
function c15146890.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少1张满足c15146890.cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c15146890.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手牌中丢弃1张满足c15146890.cfilter条件的卡，丢弃原因为REASON_COST+REASON_DISCARD
	Duel.DiscardHand(tp,c15146890.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示
function c15146890.filter(c)
	return c:IsFaceup()
end
-- 设置效果的目标选择函数，选择场上1只表侧表示怪兽作为破坏对象
function c15146890.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c15146890.filter(chkc) end
	-- 检查以玩家tp来看的场上是否存在至少1只满足c15146890.filter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c15146890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择1只满足条件的场上怪兽作为目标
	local g=Duel.SelectTarget(tp,c15146890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，说明该效果将破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果的处理函数，对选定的目标怪兽进行破坏
function c15146890.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以REASON_EFFECT原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
