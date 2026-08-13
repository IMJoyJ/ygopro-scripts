--道連れ
-- 效果：
-- ①：怪兽被战斗破坏送去自己墓地时或者场上的怪兽被送去自己墓地时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c37580756.initial_effect(c)
	-- ①：怪兽被战斗破坏送去自己墓地时或者场上的怪兽被送去自己墓地时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c37580756.condition)
	e1:SetTarget(c37580756.target)
	e1:SetOperation(c37580756.activate)
	c:RegisterEffect(e1)
end
-- 筛选送去墓地的卡中，属于怪兽、控制者为发动方tp且离场前位于主要怪兽区的卡，用于判定是否满足“自己场上的怪兽被送去自己墓地”的事件条件。
function c37580756.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查本次送去墓地的卡组中是否存在至少1张满足filter条件的卡，即判定“怪兽被战斗破坏送去自己墓地时或者场上的怪兽被送去自己墓地时”的发动条件是否成立。
function c37580756.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37580756.filter,1,nil,tp)
end
-- 效果发动时的取对象处理：确认对象必须位于场上怪兽区域；在发动时选择场上1只怪兽作为对象，并设置破坏的操作信息。
function c37580756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在效果发动的合法性检查（chk==0）时，确认场上是否存在至少1张可选择为对象的卡，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动玩家从双方主要怪兽区选择1张卡作为对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁的操作信息：将执行破坏1张卡的效果，对象为已选择的目标g，供其他卡在连锁判定时使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时：取得对象卡，若该卡仍与本效果关联（未被离场等），则将其破坏。
function c37580756.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏，使其送去墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
