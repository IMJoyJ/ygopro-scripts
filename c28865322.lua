--魔装邪龍 イーサルウェポン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，把自己墓地1只「魔装战士」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功时，以场上1只怪兽为对象才能发动。那只怪兽除外。
function c28865322.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，把自己墓地1只「魔装战士」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c28865322.descost)
	e2:SetTarget(c28865322.destg)
	e2:SetOperation(c28865322.desop)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤·特殊召唤成功时，以场上1只怪兽为对象才能发动。那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetTarget(c28865322.remtg)
	e3:SetOperation(c28865322.remop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于检查是否满足除外条件（魔装战士卡牌、怪兽类型、可除外）
function c28865322.cfilter(c)
	return c:IsSetCard(0xca) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用支付处理，检查并选择1张墓地的魔装战士怪兽除外作为费用
function c28865322.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡片（用于费用支付阶段）
	if chk==0 then return Duel.IsExistingMatchingCard(c28865322.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张墓地魔装战士怪兽
	local g=Duel.SelectMatchingCard(tp,c28865322.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以除外形式移除（作为费用）
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置灵摆效果的目标选择处理，选择场上任意1张卡作为破坏对象
function c28865322.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在满足条件的卡片（用于效果发动阶段）
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定破坏效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行灵摆效果的破坏操作，将目标卡破坏
function c28865322.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以破坏形式处理
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 设置召唤/特殊召唤成功时的效果目标选择处理，选择场上1只怪兽除外
function c28865322.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 检查场上是否存在满足条件的怪兽（用于效果发动阶段）
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只怪兽作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，确定除外效果的处理对象
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行召唤/特殊召唤成功时的效果，将目标怪兽除外
function c28865322.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以除外形式处理
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
