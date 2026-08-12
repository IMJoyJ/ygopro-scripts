--火遁封印式
-- 效果：
-- 1回合1次，可以把自己墓地1只炎属性怪兽从游戏中除外，选择对方墓地1张卡从游戏中除外。
function c52971944.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把自己墓地1只炎属性怪兽从游戏中除外，选择对方墓地1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52971944,1))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c52971944.cost)
	e2:SetTarget(c52971944.target)
	e2:SetOperation(c52971944.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断墓地中的炎属性怪兽是否满足被除外的条件
function c52971944.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 费用处理函数，检查是否能支付费用并选择除外墓地中的炎属性怪兽
function c52971944.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在至少1张满足条件的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52971944.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地中选择1张满足条件的炎属性怪兽
	local cg=Duel.SelectMatchingCard(tp,c52971944.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外作为费用
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
end
-- 目标选择函数，用于选择对方墓地中的1张卡作为除外对象
function c52971944.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地中是否存在至少1张可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地中1张可除外的卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，记录本次效果将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理函数，执行将目标卡从游戏中除外的操作
function c52971944.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为目标的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
