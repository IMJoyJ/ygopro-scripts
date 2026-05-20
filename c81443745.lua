--水遁封印式
-- 效果：
-- 1回合1次，可以把手卡1只水属性怪兽送去墓地，选择对方墓地存在的1张卡从游戏中除外。
function c81443745.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 1回合1次，可以把手卡1只水属性怪兽送去墓地，选择对方墓地存在的1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81443745,0))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c81443745.cost)
	e2:SetTarget(c81443745.target)
	e2:SetOperation(c81443745.operation)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以作为代价送去墓地的水属性怪兽
function c81443745.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGraveAsCost()
end
-- 发动代价：将手卡1只水属性怪兽送去墓地
function c81443745.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在可以作为代价送去墓地的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81443745.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡1只满足条件的水属性怪兽
	local cg=Duel.SelectMatchingCard(tp,c81443745.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(cg,REASON_COST)
end
-- 选择对方墓地1张卡作为效果的对象
function c81443745.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为除外对方墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理：将选择的对方墓地的卡除外
function c81443745.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
