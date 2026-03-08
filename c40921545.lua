--ヴェルズ・カイトス
-- 效果：
-- 把这张卡解放发动。选择对方场上存在的1张魔法·陷阱卡破坏。
function c40921545.initial_effect(c)
	-- 把这张卡解放发动。选择对方场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40921545,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c40921545.cost)
	e1:SetTarget(c40921545.target)
	e1:SetOperation(c40921545.operation)
	c:RegisterEffect(e1)
end
-- 检查是否可以支付解放作为费用
function c40921545.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤对方场上的魔法·陷阱卡
function c40921545.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择对方场上存在的1张魔法·陷阱卡作为破坏对象
function c40921545.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) end
	-- 确认对方场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c40921545.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标魔法·陷阱卡
	local g=Duel.SelectTarget(tp,c40921545.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c40921545.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
