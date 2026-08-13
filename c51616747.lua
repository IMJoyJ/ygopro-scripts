--ヌビアガード
-- 效果：
-- 这张卡对对方造成战斗伤害时，可以将自己墓地里的1张永续魔法卡弹回卡组最上面。
function c51616747.initial_effect(c)
	-- 这张卡对对方造成战斗伤害时，可以将自己墓地里的1张永续魔法卡弹回卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51616747,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c51616747.condition)
	e1:SetTarget(c51616747.target)
	e1:SetOperation(c51616747.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定受到战斗伤害的玩家不是这张卡的控制者，即必须是对对方造成战斗伤害时才满足发动条件。
function c51616747.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 筛选条件：目标必须是永续魔法卡（类型为魔法卡+永续），并且可以被送回卡组。
function c51616747.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToDeck()
end
-- 效果发动时的目标处理流程：先校验指定对象是否合法，再检查自己墓地是否存在符合条件的永续魔法卡，存在则提示玩家选择1张作为对象，并设置回卡组的操作信息。
function c51616747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51616747.filter(chkc) end
	-- 发动合法性检查：确认自己墓地是否存在至少1张符合条件的永续魔法卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51616747.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给当前玩家显示选择提示信息，提示选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张满足条件的永续魔法卡作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c51616747.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：将选择的目标及其数量登记为回卡组类别，供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：取回发动时选择的目标，若目标仍与效果关联，则将其送回持有者卡组最顶端。
function c51616747.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取回效果发动时选择的目标卡（那张永续魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回持有者卡组最顶端，即弹回卡组最上面。
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
