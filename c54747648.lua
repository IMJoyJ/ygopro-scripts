--玄武の召喚士
-- 效果：
-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只怪兽破坏。
function c54747648.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上1只怪兽为对象发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54747648,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c54747648.target)
	e1:SetOperation(c54747648.operation)
	c:RegisterEffect(e1)
end
-- 效果①的靶向处理函数，用于选择对方场上1只怪兽作为对象并设置破坏的操作信息
function c54747648.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示该效果的处理为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的执行处理函数，用于破坏作为对象的怪兽
function c54747648.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将该怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
