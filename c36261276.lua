--亜空間物質転送装置
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只自己的表侧表示怪兽直到结束阶段除外。
function c36261276.initial_effect(c)
	-- 创建效果，设置效果分类为除外，设置效果属性为取对象，设置效果类型为发动，设置效果代码为自由时点，设置效果目标函数为c36261276.target，设置效果处理函数为c36261276.operation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36261276.target)
	e1:SetOperation(c36261276.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示且能被除外
function c36261276.filter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果目标处理函数，判断是否能选择满足条件的怪兽作为对象
function c36261276.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c36261276.filter(chkc) end
	-- 检查是否满足发动条件，即场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c36261276.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c36261276.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，记录将要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，处理将目标怪兽除外并设置结束阶段返回场上的效果
function c36261276.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且满足除外条件，若满足则执行除外操作
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		-- 创建结束阶段触发的效果，用于在结束阶段将怪兽返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetOperation(c36261276.retop)
		-- 将创建的效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回场上效果处理函数，将指定怪兽返回场上
function c36261276.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将指定怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
