--道連れ
-- 效果：
-- ①：怪兽被战斗破坏送去自己墓地时或者场上的怪兽被送去自己墓地时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
function c37580756.initial_effect(c)
	-- 效果原文内容：①：怪兽被战斗破坏送去自己墓地时或者场上的怪兽被送去自己墓地时，以场上1只怪兽为对象才能发动。那只怪兽破坏。
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
-- 检索满足条件的卡片组：检查是否为怪兽卡、是否为当前控制者、是否之前在主要怪兽区
function c37580756.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断效果是否可以发动：检查是否有满足filter条件的卡进入墓地
function c37580756.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37580756.filter,1,nil,tp)
end
-- 设置效果目标：选择场上1只怪兽作为破坏对象
function c37580756.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 判断是否满足发动条件：确认场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：确定要破坏的怪兽数量和类型为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将选中的怪兽破坏
function c37580756.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
