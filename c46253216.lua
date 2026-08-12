--フレンドリーファイア
-- 效果：
-- ①：对方的魔法·陷阱·怪兽的效果发动时，以那张卡以外的场上1张卡为对象才能发动。作为对象的卡破坏。
function c46253216.initial_effect(c)
	-- 效果发动条件：对方的魔法·陷阱·怪兽的效果发动时，以那张卡以外的场上1张卡为对象才能发动。作为对象的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c46253216.condition)
	e1:SetTarget(c46253216.target)
	e1:SetOperation(c46253216.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：对方发动效果时才能发动
function c46253216.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤函数：选择的卡不能是发动效果的卡
function c46253216.filter(c,rc)
	return c~=rc
end
-- 效果处理目标选择阶段：选择场上1张满足条件的卡作为对象
function c46253216.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c46253216.filter(chkc,re:GetHandler()) and chkc~=e:GetHandler() end
	-- 检查阶段：确认场上是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c46253216.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),re:GetHandler()) end
	-- 提示信息：向玩家显示“请选择要破坏的卡”的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从场上选择1张满足条件的卡作为破坏对象
	local g=Duel.SelectTarget(tp,c46253216.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),re:GetHandler())
	-- 设置操作信息：将本次效果的处理类别设为破坏效果，目标为已选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：将选中的卡破坏
function c46253216.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行破坏操作：将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
