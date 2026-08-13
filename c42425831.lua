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
	-- 1回合1次，可以让自己场上表侧表示存在的1只风属性怪兽回到卡组最下面，选择对方墓地最多2张卡从游戏中除外。
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
-- 过滤函数：判定怪兽是否为表侧表示、风属性、且可以作为代价返回卡组，用于选择cost对象。
function c42425831.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeckAsCost()
end
-- 支付代价：从自己场上选择1只表侧表示的风属性怪兽返回卡组最下面，作为发动效果的代价。
function c42425831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足cfilter条件的怪兽，以确定cost能否支付。
	if chk==0 then return Duel.IsExistingMatchingCard(c42425831.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上表侧表示的风属性怪兽中选择1张作为代价返回卡组的卡。
	local cg=Duel.SelectMatchingCard(tp,c42425831.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的卡送去持有者卡组最下面，处理原因为代价（REASON_COST）。
	Duel.SendtoDeck(cg,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 设定效果的发动对象：选择对方墓地最多2张可除外的卡作为对象，并登记操作信息。
function c42425831.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可除外的卡，作为效果能否取对象发动的条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方墓地选择1到2张可除外的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置操作信息：本次效果将除外所选择的对象卡，分类为除外，数量为选择的数量，位置为对方墓地。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：获取发动时选择的对象，筛选仍与效果相关的卡，并将它们除外。
function c42425831.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	local rg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡以表侧表示除外，处理原因为效果（REASON_EFFECT）。
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
