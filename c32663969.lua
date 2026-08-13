--ドミノ
-- 效果：
-- 对方场上存在的怪兽被战斗破坏送去墓地时，可以把自己场上存在的1只怪兽送去墓地，对方场上存在的1只怪兽破坏。
function c32663969.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方场上存在的怪兽被战斗破坏送去墓地时，可以把自己场上存在的1只怪兽送去墓地，对方场上存在的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32663969,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c32663969.descon)
	e2:SetCost(c32663969.descost)
	e2:SetTarget(c32663969.destg)
	e2:SetOperation(c32663969.desop)
	c:RegisterEffect(e2)
end
-- 筛选被战斗破坏后进入墓地、且此前由对方控制的怪兽。
function c32663969.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- 触发条件：本组怪兽中存在至少1只“对方场上被战斗破坏送去墓地”的怪兽。
function c32663969.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c32663969.cfilter,1,nil,1-tp)
end
-- 发动代价：将自己场上1只怪兽送去墓地。
function c32663969.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测己方场上是否存在至少1只可作为代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，要求选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方场上选择1只怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的代价怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设定目标：选择对方场上1只怪兽作为对象，并登记破坏该卡的操作信息。
function c32663969.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 确认对方场上是否存在至少1只可作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，要求选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次效果将破坏1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏所选择的对方怪兽。
function c32663969.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
