--竜穴の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，另一边的自己的灵摆区域有「魔术师」卡存在的场合，把手卡1只灵摆怪兽丢弃，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- 【怪兽描述】
-- 年纪轻轻就领会唤醒龙魂的神通力的天才魔术师。由于他沉默寡言加上清心寡欲这种对魔术的态度而不擅长与人交际，但总被徒弟「龙脉之魔术师」折腾到抓狂。
function c51531505.initial_effect(c)
	-- 为这张卡注册灵摆怪兽的基础属性，使其可以灵摆召唤、作为灵摆卡发动等。
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
-- 定义效果的发动条件：自己灵摆区域存在另一张「魔术师」卡（本卡以外）。
function c51531505.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己灵摆区是否存在至少1张SetCard字段为0x98的「魔术师」卡，且排除本卡自身。
	return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x98)
end
-- 定义手牌丢弃的筛选条件：手牌中的灵摆怪兽，且可以丢弃。
function c51531505.cfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsDiscardable()
end
-- 定义效果的发动代价：丢弃手牌1只灵摆怪兽。先检查是否满足，满足后执行丢弃。
function c51531505.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段确认手牌中是否存在至少1张可丢弃的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c51531505.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家从手牌选择并丢弃1只灵摆怪兽，作为本次效果的发动代价。
	Duel.DiscardHand(tp,c51531505.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义取对象目标的筛选条件：场上的魔法·陷阱卡。
function c51531505.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果发动时的取对象处理：选择场上1张魔法·陷阱卡为对象，并设置破坏信息。
function c51531505.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51531505.filter(chkc) end
	-- 效果发动前检查双方场上是否存在至少1张可以成为对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c51531505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家弹出选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择1张魔法·陷阱卡，并将其设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c51531505.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：以选择的卡为对象，确定造成1张卡的破坏效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理时的操作：取回对象卡，若卡仍与效果相关，则将其破坏。
function c51531505.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁记录的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以“效果”为原因，将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
