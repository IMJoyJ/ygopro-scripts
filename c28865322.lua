--魔装邪龍 イーサルウェポン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，把自己墓地1只「魔装战士」怪兽除外，以场上1张卡为对象才能发动。那张卡破坏。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功时，以场上1只怪兽为对象才能发动。那只怪兽除外。
function c28865322.initial_effect(c)
	-- 使该卡注册为灵摆怪兽，获得灵摆召唤及灵摆卡发动相关属性。
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
	-- 【怪兽效果】①：这张卡召唤·特殊召唤成功时，以场上1只怪兽为对象才能发动。那只怪兽除外。
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
-- 定义代价过滤条件：卡名属于「魔装战士」字段的怪兽，且可作为代价从墓地除外。
function c28865322.cfilter(c)
	return c:IsSetCard(0xca) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理函数：确认墓地存在符合条件的「魔装战士」怪兽后，选择1张将其表侧表示除外作为发动代价。
function c28865322.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认阶段：检查自己墓地是否存在至少1张满足条件且可作为代价除外的「魔装战士」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28865322.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，告知玩家要选择除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张符合条件的「魔装战士」怪兽，作为本次发动的除外代价。
	local g=Duel.SelectMatchingCard(tp,c28865322.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，该除外行为作为效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 破坏效果的目标选择函数：选择场上1张卡作为对象，并登记破坏操作信息。
function c28865322.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动确认阶段：检查场上是否存在至少1张可以成为效果对象的卡（任意卡）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，告知玩家要选择破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象，并将其登记为当前连锁的指定对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息，宣告将对1张对象卡进行破坏，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理函数：取得对象卡，若对象仍与该效果关联，则将其破坏。
function c28865322.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中第一张被设定的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 除外效果的目标选择函数：选择场上1只怪兽作为对象，并登记除外操作信息。
function c28865322.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 发动确认阶段：检查场上是否存在至少1只可以被除外的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，告知玩家要选择除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只可以被除外的怪兽作为效果对象，并登记为当前连锁的指定对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息，宣告将对1只对象怪兽进行除外，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 除外效果处理函数：取得对象卡，若对象仍与该效果关联，则将其除外。
function c28865322.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中第一张被设定的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
