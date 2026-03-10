--竜穴の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- 【怪兽描述】
-- 年纪轻轻就领会唤醒龙魂的神通力的天才魔术师。由于他沉默寡言加上清心寡欲这种对魔术的态度而不擅长与人交际，但总被徒弟「龙脉之魔术师」折腾到抓狂。
function c51531505.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51531505,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c51531505.condition)
	e2:SetCost(c51531505.cost)
	e2:SetTarget(c51531505.target)
	e2:SetOperation(c51531505.operation)
	c:RegisterEffect(e2)
end
-- 判断另一边的自己的灵摆区域是否存在「魔术师」卡
function c51531505.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家tp来看的灵摆区域是否存在至少1张卡且该卡为0x98（魔术师）种族
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 过滤函数，用于筛选手牌中可以丢弃的灵摆怪兽
function c51531505.cfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 效果发动时的费用处理，要求玩家从手牌中丢弃1只灵摆怪兽
function c51531505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少1张满足c51531505.cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51531505.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌中满足条件的1张卡的操作，丢弃原因为REASON_COST+REASON_DISCARD
	Duel.DiscardHand(tp,c51531505.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选场上的魔法或陷阱卡
function c51531505.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择逻辑，允许选择场上任意一张魔法或陷阱卡作为破坏对象
function c51531505.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51531505.filter(chkc) end
	-- 检查以玩家tp来看的场上是否存在至少1张满足c51531505.filter条件的卡
	if chk==0 then return Duel.IsExistingTarget(c51531505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的1张场上的魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c51531505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，指定将要破坏的目标卡数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理逻辑，对选定的目标卡进行破坏
function c51531505.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以REASON_EFFECT原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
