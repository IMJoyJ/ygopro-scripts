--木遁封印式
-- 效果：
-- 1回合1次，可以把自己场上表侧表示存在的1只地属性怪兽解放，选择对方墓地存在的最多2张卡从游戏中除外。
function c1802450.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己场上表侧表示存在的1只地属性怪兽解放，选择对方墓地存在的最多2张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1802450,1))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c1802450.cost)
	e2:SetTarget(c1802450.target)
	e2:SetOperation(c1802450.operation)
	c:RegisterEffect(e2)
end
-- 定义过滤器：筛选表侧表示且属性为地属性的怪兽，用于作为解放代价的候选。
function c1802450.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 代价处理：从自己场上选择并解放1只表侧表示的地属性怪兽作为发动代价。
function c1802450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动代价：自己场上是否存在至少1只可解放的表侧地属性怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1802450.cfilter,1,nil) end
	-- 选择1只表侧表示的地属性怪兽作为解放对象。
	local cg=Duel.SelectReleaseGroup(tp,c1802450.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为发动效果的COST。
	Duel.Release(cg,REASON_COST)
end
-- 发动时选择对象：从对方墓地选择1~2张可除外的卡作为效果对象，并设置除外相关操作信息。
function c1802450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否满足发动条件：对方墓地是否存在至少1张可除外的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 弹出选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1~2张可除外的卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置操作信息，记录本次效果将除外这些卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：获取连锁中确定的对象卡，并将仍然与效果相关的卡除外。
function c1802450.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的效果对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡以表侧表示从墓地除外，完成除外处理。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
