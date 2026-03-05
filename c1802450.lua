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
-- 过滤函数，用于判断场上是否存在满足条件的可解放地属性怪兽
function c1802450.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 检查是否满足解放条件并选择1只地属性怪兽进行解放
function c1802450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放地属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1802450.cfilter,1,nil) end
	-- 选择1只满足条件的可解放地属性怪兽
	local cg=Duel.SelectReleaseGroup(tp,c1802450.cfilter,1,1,nil)
	-- 将选中的怪兽以支付代价的方式进行解放
	Duel.Release(cg,REASON_COST)
end
-- 选择对方墓地存在的最多2张可除外的卡作为效果对象
function c1802450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在至少1张可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地存在的1到2张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置效果处理时要除外的卡组及数量信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 执行效果，将选中的卡从游戏中除外
function c1802450.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已选定的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
