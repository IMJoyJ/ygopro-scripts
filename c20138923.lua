--反魔鏡
-- 效果：
-- 对方把速攻魔法卡发动时才能发动。选择场上存在的1张卡破坏。
function c20138923.initial_effect(c)
	-- 创建效果，设置效果类别为破坏，类型为发动，属性为取对象，触发事件为连锁发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c20138923.condition)
	e1:SetTarget(c20138923.target)
	e1:SetOperation(c20138923.activate)
	c:RegisterEffect(e1)
end
-- 对方把速攻魔法卡发动时才能发动
function c20138923.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 选择场上存在的1张卡破坏
function c20138923.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc~=e:GetHandler() end
	-- 检查场上是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息，确定破坏效果的目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时，将目标卡破坏
function c20138923.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
