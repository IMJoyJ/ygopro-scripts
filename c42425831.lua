--雷遁封印式
-- 效果：
-- 1回合1次，可以让自己场上表侧表示存在的1只风属性怪兽回到卡组最下面，选择对方墓地最多2张卡从游戏中除外。
function c42425831.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 效果原文内容：1回合1次，可以让自己场上表侧表示存在的1只风属性怪兽回到卡组最下面，选择对方墓地最多2张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42425831,0))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c42425831.cost)
	e2:SetTarget(c42425831.target)
	e2:SetOperation(c42425831.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的风属性怪兽（正面表示且能送回卡组）
function c42425831.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeckAsCost()
end
-- 效果处理的费用支付阶段，检查场上是否存在风属性怪兽并将其送回卡组底端
function c42425831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足条件的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42425831.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送回卡组的风属性怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上1只满足条件的风属性怪兽
	local cg=Duel.SelectMatchingCard(tp,c42425831.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的风属性怪兽送回卡组底端
	Duel.SendtoDeck(cg,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 效果处理的目标选择阶段，选择对方墓地最多2张可除外的卡
function c42425831.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1至2张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置效果处理信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理的执行阶段，将选中的卡从游戏中除外
function c42425831.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	local rg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组中的卡从游戏中除外
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
