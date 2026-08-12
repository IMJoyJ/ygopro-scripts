--サイクロン
-- 效果：
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c5318639.initial_effect(c)
	-- 旋风效果定义，对应效果原文“①：以场上 1 张魔法·陷阱卡为对象才能发动。那张卡破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c5318639.target)
	e1:SetOperation(c5318639.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的卡片，判断是否为魔法或陷阱卡
function c5318639.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择处理函数，定义对象范围和限制
function c5318639.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5318639.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在符合条件的魔法·陷阱卡作为发动对象
	if chk==0 then return Duel.IsExistingTarget(c5318639.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示选择破坏对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择 1 张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c5318639.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息，指定破坏目标及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动后的处理函数，执行破坏操作
function c5318639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前选定的目标卡片对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏指定的魔法·陷阱卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
