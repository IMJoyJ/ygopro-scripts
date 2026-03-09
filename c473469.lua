--猛吹雪
-- 效果：
-- 自己的陷阱卡被对方控制的卡的效果破坏，从场地送去墓地时才能发动。场上的1张魔法·陷阱卡破坏。
function c473469.initial_effect(c)
	-- 效果原文内容：自己的陷阱卡被对方控制的卡的效果破坏，从场地送去墓地时才能发动。场上的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c473469.condition)
	e1:SetTarget(c473469.target)
	e1:SetOperation(c473469.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：自身为陷阱卡、之前在场上、之前由自己控制、破坏原因包含REASON_EFFECT和REASON_DESTROY
function c473469.filter(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
		and bit.band(c:GetReason(),0x41)==0x41
end
-- 判断是否满足发动条件：对方玩家处理效果、场上存在满足filter条件的卡片
function c473469.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c473469.filter,1,nil,tp)
end
-- 筛选目标卡片类型：魔法或陷阱卡
function c473469.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的目标选择逻辑：选择场上的魔法·陷阱卡作为破坏对象
function c473469.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c473469.desfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查是否满足发动条件：确认场上存在可破坏的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c473469.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择一个目标卡片作为破坏对象
	local g=Duel.SelectTarget(tp,c473469.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将破坏效果加入连锁处理中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时执行的操作：对选定的目标进行破坏
function c473469.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
